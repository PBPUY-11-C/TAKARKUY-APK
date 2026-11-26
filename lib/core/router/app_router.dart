import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:takarkuy_apk/app/menu_page.dart';
import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/features/akun/screens/profile_page.dart';
import 'package:takarkuy_apk/features/akun/screens/signup_page.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';
import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';
import 'package:takarkuy_apk/features/planner/screens/create_plan_page.dart';
import 'package:takarkuy_apk/features/planner/screens/plan_detail_page.dart';
import 'package:takarkuy_apk/features/recipe_book/screens/recipe_list_page.dart';

/// Alamat setiap halaman utama; modul memakai konstanta ini, bukan menulis string sendiri.
abstract final class AppRoutes {
  static const home = '/';
  static const planner = '/planner';
  static const plannerNew = '/planner/new';
  static String plannerDetail(String id) => '/planner/plans/$id';
  static const pantry = '/pantry';
  static const resep = '/resep';
  static const dashboard = '/dashboard';
  static const login = '/login';
  static const signup = '/signup';
  static const account = '/account';

  static const transitionDuration = Duration(milliseconds: 260);
}

/// Membuat router aplikasi; dipanggil sekali di akar aplikasi.
GoRouter createAppRouter(AuthState authState) => GoRouter(
  refreshListenable: authState,
  redirect: (context, state) {
    final path = state.uri.path;
    const protected = {
      AppRoutes.planner,
      AppRoutes.plannerNew,
      AppRoutes.pantry,
      AppRoutes.resep,
      AppRoutes.dashboard,
      AppRoutes.account,
    };
    final isProtected = protected.contains(path) || path.startsWith('${AppRoutes.planner}/');
    if (isProtected && !authState.isAuthenticated) {
      return AppRoutes.login;
    }
    if (path == AppRoutes.login && authState.isAuthenticated) {
      return AppRoutes.dashboard;
    }
    return null;
  },
  routes: [
    _route(AppRoutes.home, const MenuPage()),
    _route(AppRoutes.planner, const PlannerPage()),
    _route(AppRoutes.plannerNew, const CreatePlanPage()),
    _routeWith('/planner/plans/:id', (state) => PlanDetailPage(planId: state.pathParameters['id']!)),
    _route(AppRoutes.pantry, const PantryPage()),
    _route(AppRoutes.resep, const RecipeListPage()),
    _route(AppRoutes.dashboard, const DashboardScreen()),
    _route(AppRoutes.login, const AkunPage()),
    _route(AppRoutes.signup, const SignupPage()),
    _route(AppRoutes.account, const AccountProfilePage()),
  ],
);

/// Rute dengan transisi bersama: halaman baru memudar sambil sedikit naik.
GoRoute _route(String path, Widget page) => _routeWith(path, (_) => page);

/// Sama dengan `_route`, untuk halaman yang butuh parameter dari alamat (mis. `:id`).
GoRoute _routeWith(String path, Widget Function(GoRouterState state) build) => GoRoute(
  path: path,
  pageBuilder: (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    name: path,
    // `extra` diteruskan sebagai arguments agar ModalRoute.settings.arguments tetap terbaca.
    arguments: state.extra,
    transitionDuration: AppRoutes.transitionDuration,
    reverseTransitionDuration: AppRoutes.transitionDuration,
    child: build(state),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  ),
);
