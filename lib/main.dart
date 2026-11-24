import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_theme.dart';

void main() {
  runApp(const TakarKuyApp());
}

/// Akar aplikasi: sesi login (CookieRequest), ApiClient, tema, dan router dibuat sekali di sini
/// untuk semua modul. `request` bisa diganti server palsu saat tes.
class TakarKuyApp extends StatefulWidget {
  const TakarKuyApp({super.key, this.request});

  final CookieRequest? request;

  @override
  State<TakarKuyApp> createState() => _TakarKuyAppState();
}

class _TakarKuyAppState extends State<TakarKuyApp> {
  // Router dan sesi disimpan di state agar tidak hilang saat widget dibangun ulang.
  final GoRouter _router = createAppRouter();
  late final CookieRequest _request = widget.request ?? CookieRequest();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CookieRequest>.value(value: _request),
        Provider<ApiClient>(create: (_) => ApiClient(_request)),
      ],
      child: MaterialApp.router(
        title: 'TAKARKUY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
