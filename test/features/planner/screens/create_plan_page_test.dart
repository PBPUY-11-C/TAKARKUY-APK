import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/data/plan_models.dart';
import 'package:takarkuy_apk/features/planner/screens/create_plan_page.dart';

import '../planner_fixtures.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532);
    view.devicePixelRatio = 3;
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset());

  /// Membuka form dari tombol di layar lain agar hasil `Navigator.pop` bisa diperiksa.
  Future<List<PlanDetail?>> pumpForm(WidgetTester tester, http.Response Function(http.Request) reply,
      {List<http.Request>? requests}) async {
    final results = <PlanDetail?>[];
    final api = ApiClient(
      client: MockClient((request) async {
        requests?.add(request);
        return reply(request);
      }),
      baseUrl: 'https://api.test',
    );
    await tester.pumpWidget(Provider.value(
      value: api,
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.push<PlanDetail>(context, MaterialPageRoute(builder: (_) => const CreatePlanPage())),
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    return results;
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
  }

  testWidgets('langkah budget menghitung per orang per hari dan pilihan cepat mengisi budget', (tester) async {
    await pumpForm(tester, (_) => http.Response('{}', 200));

    expect(find.text('Rp25.000'), findsOneWidget);
    await tester.tap(find.text('100rb'));
    await tester.pump();
    expect(find.widgetWithText(TextField, '100.000'), findsOneWidget);
    expect(find.text('Rp16.666'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah hari'));
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('langkah preferensi menahan pengguna sampai target gizi dipilih', (tester) async {
    await pumpForm(tester, (_) => http.Response('{}', 200));
    await next(tester);

    await tester.tap(find.text('Seimbang'));
    await tester.pump();
    await next(tester);
    expect(find.text('Pilih minimal satu target gizi.'), findsOneWidget);

    await tester.tap(find.text('Tinggi protein'));
    await tester.pump();
    await next(tester);
    expect(find.text('Periksa sebelum disusun'), findsOneWidget);
    expect(find.text('Tinggi protein'), findsOneWidget);
  });

  testWidgets('ringkasan lalu Buat rencana mengirim isian dan menutup form dengan hasilnya', (tester) async {
    final requests = <http.Request>[];
    final results = await pumpForm(tester, (_) => http.Response(jsonEncode(detailJson), 201), requests: requests);
    await next(tester);
    await next(tester);

    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('3 hari · 2 orang'), findsOneWidget);
    await tester.tap(find.text('Buat rencana'));
    await tester.pumpAndSettle();

    expect(requests.single.method, 'POST');
    expect(results.single!.summary.title, 'Rencana Makan Saya');
    expect(find.byType(CreatePlanPage), findsNothing);
  });

  testWidgets('budget kurang menampilkan pesan server dan form tetap terbuka', (tester) async {
    await pumpForm(tester, (_) => http.Response(jsonEncode({'error': 'Budget belum cukup untuk menu ini.'}), 400));
    await next(tester);
    await next(tester);

    await tester.tap(find.text('Buat rencana'));
    await tester.pumpAndSettle();

    expect(find.text('Budget belum cukup untuk menu ini.'), findsOneWidget);
    expect(find.byType(CreatePlanPage), findsOneWidget);
  });

  testWidgets('draft lama memunculkan dialog; Ganti draft mengirim ulang dengan persetujuan', (tester) async {
    var posts = 0;
    final requests = <http.Request>[];
    final results = await pumpForm(tester, (request) {
      if (request.method == 'GET') return http.Response(jsonEncode([summaryJson]), 200);
      posts++;
      return posts == 1
          ? http.Response(jsonEncode({'error': 'Setujui penggantian draft.'}), 409)
          : http.Response(jsonEncode(detailJson), 201);
    }, requests: requests);
    await next(tester);
    await next(tester);

    await tester.tap(find.text('Buat rencana'));
    await tester.pumpAndSettle();
    expect(find.text('Ganti draft lama?'), findsOneWidget);

    await tester.tap(find.text('Ganti draft'));
    await tester.pumpAndSettle();

    expect((jsonDecode(requests.last.body) as Map)['replace_draft'], isTrue);
    expect(results.single, isNotNull);
  });
}
