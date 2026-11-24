import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/core/widgets/async_state_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('menampilkan indikator memuat saat data belum ada', (tester) async {
    await tester.pumpWidget(_wrap(AsyncStateView(loading: true, builder: (_) => const Text('isi'))));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Memuat'), findsOneWidget);
    expect(find.text('isi'), findsNothing);
  });

  testWidgets('menampilkan pesan error dan tombol Coba lagi yang memanggil onRetry', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(AsyncStateView(
      error: 'Tidak bisa terhubung ke server.',
      onRetry: () => retried++,
      builder: (_) => const Text('isi'),
    )));

    expect(find.text('Tidak bisa terhubung ke server.'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    expect(retried, 1);
  });

  testWidgets('menampilkan pesan kosong bila tidak ada data', (tester) async {
    await tester.pumpWidget(_wrap(AsyncStateView(
      empty: true,
      emptyMessage: 'Belum ada rencana.',
      builder: (_) => const Text('isi'),
    )));

    expect(find.text('Belum ada rencana.'), findsOneWidget);
    expect(find.text('isi'), findsNothing);
  });

  testWidgets('menampilkan isi saat data siap', (tester) async {
    await tester.pumpWidget(_wrap(AsyncStateView(builder: (_) => const Text('isi'))));

    expect(find.text('isi'), findsOneWidget);
  });

  testWidgets('saat memuat ulang, isi lama tetap tampil', (tester) async {
    await tester.pumpWidget(_wrap(AsyncStateView(
      loading: true,
      hasData: true,
      builder: (_) => const Text('isi lama'),
    )));

    expect(find.text('isi lama'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
