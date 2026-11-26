import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
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
      const protected = {
        AppRoutes.planner,
        AppRoutes.pantry,
        AppRoutes.resep,
        AppRoutes.dashboard,
      };
      await tester.pumpWidget(
        TakarKuyApp(
          initialToken: protected.contains(entry.key) ? 'test-token' : null,
        ),
      );
      final router = GoRouter.of(tester.element(find.byType(MenuPage)));
      router.go(entry.key);
      await tester.pumpAndSettle();

      expect(find.byType(entry.value), findsOneWidget);
    });
  }

  testWidgets('perpindahan halaman memakai transisi bersama', (tester) async {
    await tester.pumpWidget(const TakarKuyApp(initialToken: 'test-token'));
    GoRouter.of(tester.element(find.byType(MenuPage))).push(AppRoutes.planner);
    await tester.pumpAndSettle();

    final route = ModalRoute.of(tester.element(find.byType(PlannerPage)))!;
    expect(route.transitionDuration, AppRoutes.transitionDuration);
  });

  testWidgets('kembali dari halaman modul ke halaman awal', (tester) async {
    await tester.pumpWidget(const TakarKuyApp(initialToken: 'test-token'));
    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();
    expect(find.byType(PantryPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
  });

  testWidgets('rute modul yang dilindungi mengarahkan tamu ke login', (
    tester,
  ) async {
    await tester.pumpWidget(const TakarKuyApp());
    final router = GoRouter.of(tester.element(find.byType(MenuPage)));
    router.go(AppRoutes.planner);
    await tester.pumpAndSettle();

    expect(find.byType(AkunPage), findsOneWidget);
    expect(find.byType(PlannerPage), findsNothing);
  });

  testWidgets('halaman akun memuat profil lewat token dan menyediakan logout', (
    tester,
  ) async {
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Token token-123');
      return http.Response(
        jsonEncode({
          'username': 'attarrais',
          'full_name': 'Attar Rais',
          'email': 'attar@example.com',
          'avatar': 'chef',
          'preferences': {
            'targets': ['seimbang'],
            'allergens': [],
          },
        }),
        200,
      );
    });
    await tester.pumpWidget(
      TakarKuyApp(
        initialToken: 'token-123',
        initialUsername: 'attarrais',
        client: client,
      ),
    );
    GoRouter.of(tester.element(find.byType(MenuPage))).go(AppRoutes.account);
    await tester.pumpAndSettle();

    expect(find.text('Attar Rais'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });
}
