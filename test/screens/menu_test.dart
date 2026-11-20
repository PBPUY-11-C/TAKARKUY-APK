import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/main.dart';
import 'package:takarkuy_apk/pantry/screens/pantry_page.dart';
import 'package:takarkuy_apk/planner/planner_page.dart';

void main() {
  // Ukuran layar HP umum (360 x 800) agar kelima kartu terlihat tanpa scroll.
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  testWidgets('halaman awal menampilkan nama aplikasi dan kelima modul', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());

    expect(find.text('TAKARKUY'), findsOneWidget);
    for (final name in ['Planner', 'Pantry', 'Akun', 'Resep', 'Dashboard']) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('kartu Planner membuka halaman Planner', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();

    expect(find.byType(PlannerPage), findsOneWidget);
  });

  testWidgets('kartu Pantry membuka halaman Pantry', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();

    expect(find.byType(PantryPage), findsOneWidget);
  });

  testWidgets('kartu Dashboard membuka Dashboard', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('modul yang belum punya halaman memberi tahu "segera hadir"', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Resep'));
    await tester.pump();

    expect(find.text('Halaman Resep segera hadir.'), findsOneWidget);
  });
}
