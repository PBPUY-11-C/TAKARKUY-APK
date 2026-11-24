import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:takarkuy_apk/app/menu_page.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/features/akun/screens/signup_page.dart';
import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';
import 'package:takarkuy_apk/features/recipe_book/screens/recipe_list_page.dart';
import 'package:takarkuy_apk/main.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  final pages = <String, Type>{
    AppRoutes.home: MenuPage,
    AppRoutes.planner: PlannerPage,
    AppRoutes.pantry: PantryPage,
    AppRoutes.resep: RecipeListPage,
    AppRoutes.dashboard: DashboardScreen,
    AppRoutes.login: AkunPage,
    AppRoutes.signup: SignupPage,
  };

  for (final entry in pages.entries) {
    testWidgets('rute ${entry.key} membuka ${entry.value}', (tester) async {
      await tester.pumpWidget(const TakarKuyApp());
      final router = GoRouter.of(tester.element(find.byType(MenuPage)));
      router.go(entry.key);
      await tester.pumpAndSettle();

      expect(find.byType(entry.value), findsOneWidget);
    });
  }

  testWidgets('perpindahan halaman memakai transisi bersama', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    GoRouter.of(tester.element(find.byType(MenuPage))).push(AppRoutes.planner);
    await tester.pumpAndSettle();

    final route = ModalRoute.of(tester.element(find.byType(PlannerPage)))!;
    expect(route.transitionDuration, AppRoutes.transitionDuration);
  });

  testWidgets('kembali dari halaman modul ke halaman awal', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();
    expect(find.byType(PantryPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
  });
}
