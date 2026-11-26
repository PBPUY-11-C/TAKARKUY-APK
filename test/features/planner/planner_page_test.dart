import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/planner_format.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';
import 'package:takarkuy_apk/features/planner/providers/planner_provider.dart';

import 'planner_fixtures.dart';

final _saved = {...summaryJson, 'id': 'b2', 'title': 'Akhir Pekan', 'status': 'saved', 'version': 2};

/// Memasang halaman Planner dengan server palsu; `reply` bisa diganti di tengah tes.
class _Harness {
  http.Response Function(http.Request request) reply = (_) => http.Response(jsonEncode([summaryJson, _saved]), 200);
  final requests = <http.Request>[];

  Future<void> pump(WidgetTester tester) async {
    final api = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return reply(request);
      }),
      baseUrl: 'https://api.test',
    );
    await tester.pumpWidget(Provider.value(value: api, child: const MaterialApp(home: PlannerPage())));
    await tester.pumpAndSettle();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('format rupiah dan tanggal mengikuti gaya web', () {
    expect(formatRupiah(133500), 'Rp 133.500');
    expect(formatRupiah(5500), 'Rp 5.500');
    expect(formatShortDate(DateTime(2026, 11, 25)), '25 Nov 2026');
  });

  testWidgets('menampilkan daftar Rencana Saya dari API', (tester) async {
    await _Harness().pump(tester);

    expect(find.text('Meal Planner'), findsOneWidget);
    expect(find.text('Rencana Saya'), findsOneWidget);
    expect(find.text('Rencana Makan Saya'), findsOneWidget);
    expect(find.text('Akhir Pekan'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Tersimpan'), findsOneWidget);
    expect(find.text('Rp 120.000'), findsNWidgets(2));
  });

  testWidgets('daftar kosong mengajak membuat rencana', (tester) async {
    final harness = _Harness()..reply = (_) => http.Response('[]', 200);
    await harness.pump(tester);

    expect(find.text('Belum ada rencana tersimpan.'), findsOneWidget);
  });

  testWidgets('gagal memuat menampilkan pesan dan Coba lagi memuat ulang', (tester) async {
    final harness = _Harness()..reply = (_) => throw http.ClientException('offline');
    await harness.pump(tester);
    expect(find.textContaining('Tidak bisa terhubung'), findsOneWidget);

    harness.reply = (_) => http.Response(jsonEncode([summaryJson]), 200);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Rencana Makan Saya'), findsOneWidget);
  });

  testWidgets('tanpa koneksi, daftar terakhir tampil dengan tanda offline', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);
    harness.reply = (_) => throw http.ClientException('offline');
    await tester.pumpWidget(const SizedBox());
    await harness.pump(tester);

    expect(find.text('Rencana Makan Saya'), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
  });

  testWidgets('pencarian menyaring setelah pengguna berhenti mengetik', (tester) async {
    await _Harness().pump(tester);

    await tester.enterText(find.byType(TextField), 'akhir');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Rencana Makan Saya'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Rencana Makan Saya'), findsNothing);
    expect(find.text('Akhir Pekan'), findsOneWidget);
  });

  testWidgets('geser kartu menghapusnya, dan Batal mengembalikannya tanpa mengirim apa pun', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    await tester.drag(find.text('Rencana Makan Saya'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Rencana Makan Saya'), findsNothing);
    expect(find.text('Rencana dihapus.'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    await tester.pump(PlannerProvider.undoWindow);

    expect(find.text('Rencana Makan Saya'), findsOneWidget);
    expect(harness.requests.where((r) => r.method == 'POST'), isEmpty);
  });
}
