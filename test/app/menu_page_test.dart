import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/features/recipe_book/screens/recipe_list_page.dart';
import 'package:takarkuy_apk/main.dart';
import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';

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

  testWidgets('kartu Resep membuka halaman Buku Resep', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Resep'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeListPage), findsOneWidget);
  });

  testWidgets('kartu Akun membuka halaman Akun', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();

    expect(find.byType(AkunPage), findsOneWidget);
  });
}
