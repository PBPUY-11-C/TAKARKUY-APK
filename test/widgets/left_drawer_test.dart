import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/main.dart';
import 'package:takarkuy_apk/pantry/pantry_page.dart';
import 'package:takarkuy_apk/planner/planner_page.dart';
import 'package:takarkuy_apk/recipe_book/screens/recipe_list_page.dart';
import 'package:takarkuy_apk/screens/menu.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Buka menu navigasi'));
    await tester.pumpAndSettle();
  }

  final destinations = <String, Type>{
    'Smart Meal Planner': PlannerPage,
    'Smart Pantry': PantryPage,
    'Akun & Preferensi': AkunPage,
    'Buku Resep & Masak': RecipeListPage,
    'Dashboard & Market': DashboardScreen,
  };

  for (final entry in destinations.entries) {
    testWidgets('drawer "${entry.key}" membuka halamannya', (tester) async {
      await tester.pumpWidget(const TakarKuyApp());
      await openDrawer(tester);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.byType(entry.value), findsOneWidget);
    });
  }

  testWidgets('drawer "Halaman Utama" kembali ke halaman awal', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await openDrawer(tester);
    await tester.tap(find.text('Buku Resep & Masak'));
    await tester.pumpAndSettle();

    // Halaman resep juga memakai drawer yang sama.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Halaman Utama'));
    await tester.pumpAndSettle();

    expect(find.byType(MenuPage), findsOneWidget);
    expect(find.byType(RecipeListPage), findsNothing);
  });
}
