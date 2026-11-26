import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/screens/plan_detail_page.dart';

import '../planner_fixtures.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532);
    view.devicePixelRatio = 3;
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset());

  /// Membuka detail lewat tombol supaya hasil `Navigator.pop` (true bila dihapus) bisa diperiksa.
  Future<List<Object?>> pumpDetail(WidgetTester tester, http.Response Function(http.Request) reply,
      {List<http.Request>? requests}) async {
    final results = <Object?>[];
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
            onPressed: () async => results.add(await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlanDetailPage(planId: 'f485e609-87f8-4ac3-bc2d-c0f5d3c51c76')),
            )),
            child: const Text('buka'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    return results;
  }

  http.Response ok(Object body) => http.Response(jsonEncode(body), 200);

  testWidgets('tab Jadwal menampilkan ringkasan budget dan menu hari pertama', (tester) async {
    await pumpDetail(tester, (_) => ok(detailJson));

    expect(find.text('Rencana Makan Saya'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Rp 120.000'), findsOneWidget);
    expect(find.text('/ Rp 150.000'), findsOneWidget);
    expect(find.text('Dalam budget'), findsOneWidget);
    expect(find.text('Sisa Rp 30.000'), findsOneWidget);
    expect(find.text('Kamis, 26 Nov 2026'), findsOneWidget);
    expect(find.text('Nasi Goreng Telur Pakcoy'), findsOneWidget);
    expect(find.text('Rp 6.300 · 345 kkal/porsi'), findsOneWidget);
  });

  testWidgets('tab Belanja menampilkan kelompok bahan yang bisa dibuka', (tester) async {
    await pumpDetail(tester, (_) => ok(detailJson));

    await tester.tap(find.text('Belanja'));
    await tester.pumpAndSettle();
    expect(find.text('Bumbu'), findsOneWidget);
    expect(find.text('2 bahan'), findsOneWidget);
    expect(find.text('Rp 3.500'), findsWidgets);

    await tester.tap(find.text('Bumbu'));
    await tester.pumpAndSettle();
    expect(find.text('Bawang Merah'), findsOneWidget);
    expect(find.text('35 g'), findsOneWidget);
  });

  testWidgets('tab Gizi menampilkan empat cincin terhadap acuan harian', (tester) async {
    await pumpDetail(tester, (_) => ok(detailJson));

    await tester.tap(find.text('Gizi'));
    await tester.pumpAndSettle();

    expect(find.text('1072'), findsOneWidget);
    expect(find.text('50% dari 2150 kkal'), findsOneWidget);
    expect(find.text('102% dari 60 g'), findsOneWidget);
    expect(find.text('53% dari 325 g'), findsOneWidget);
    expect(find.text('33% dari 67 g'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Energi 1072 kkal')), findsOneWidget);
  });

  testWidgets('Simpan rencana membuka lembar simpan lalu menyimpan judul baru', (tester) async {
    final requests = <http.Request>[];
    await pumpDetail(tester, (request) {
      if (request.method == 'POST') {
        return ok({...detailJson, 'id': 'saved-1', 'status': 'saved', 'title': 'Minggu ini'});
      }
      return ok(detailJson);
    }, requests: requests);

    await tester.tap(find.text('Simpan rencana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Rencana Makan Saya'), 'Minggu ini');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(requests.last.url.path, endsWith('/save/'));
    expect((jsonDecode(requests.last.body) as Map)['title'], 'Minggu ini');
    expect(find.text('Rencana tersimpan.'), findsOneWidget);
    expect(find.text('Tersimpan'), findsOneWidget);
    expect(find.text('Minggu ini'), findsOneWidget);
  });

  testWidgets('Hapus rencana meminta konfirmasi lalu menutup halaman', (tester) async {
    final requests = <http.Request>[];
    final results = await pumpDetail(
      tester,
      (request) => request.method == 'POST' ? ok({'deleted': true}) : ok(detailJson),
      requests: requests,
    );

    await tester.tap(find.byTooltip('Pilihan lain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus rencana'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus rencana ini?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(requests.last.url.path, endsWith('/delete/'));
    expect(results.single, isTrue);
    expect(find.byType(PlanDetailPage), findsNothing);
  });

  testWidgets('gagal memuat menampilkan Coba lagi', (tester) async {
    var calls = 0;
    await pumpDetail(tester, (_) => calls++ == 0 ? throw http.ClientException('offline') : ok(detailJson));

    expect(find.textContaining('Tidak bisa terhubung'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Nasi Goreng Telur Pakcoy'), findsOneWidget);
  });
}
