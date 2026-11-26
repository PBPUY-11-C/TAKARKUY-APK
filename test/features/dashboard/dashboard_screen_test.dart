import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/main.dart';

void main() {
  testWidgets('TAKARKUY dashboard loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // Memastikan aplikasi berhasil dijalankan.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Memastikan konten dashboard muncul.
    expect(find.text('Pintasan Modul'), findsOneWidget);
    expect(find.text('Hai, selamat datang 👋'), findsOneWidget);

    // Memastikan navigasi utama tersedia.
    final navigationBar = find.byType(BottomNavigationBar);

    expect(navigationBar, findsOneWidget);

    expect(
      find.descendant(of: navigationBar, matching: find.text('Dashboard')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: navigationBar, matching: find.text('Resep Saya')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: navigationBar, matching: find.text('Market')),
      findsOneWidget,
    );
  });

  testWidgets('dashboard guest dialihkan ke login dan dapat membuka daftar', (
    tester,
  ) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);

    await tester.tap(find.text('DaftarKuy'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Akun'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);

    await tester.tap(find.text('Kembali ke beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Akun'), findsOneWidget);
  });
}
