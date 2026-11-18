
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/main.dart';

void main() {
  testWidgets('TAKARKUY dashboard loads successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Memastikan aplikasi berhasil dijalankan.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Memastikan konten dashboard muncul.
    expect(find.text('Pintasan Modul'), findsOneWidget);
    expect(find.text('Hai, selamat datang 👋'), findsOneWidget);

    // Memastikan navigasi utama tersedia.
    final navigationBar = find.byType(BottomNavigationBar);

    expect(navigationBar, findsOneWidget);

    expect(
      find.descendant(
        of: navigationBar,
        matching: find.text('Dashboard'),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: navigationBar,
        matching: find.text('Resep Saya'),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: navigationBar,
        matching: find.text('Market'),
      ),
      findsOneWidget,
    );
  });
}
