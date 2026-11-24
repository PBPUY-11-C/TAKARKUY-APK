import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_theme.dart';

void main() {
  runApp(const TakarKuyApp());
}

/// Akar aplikasi: tema bersama dan router dibuat sekali di sini untuk semua modul.
class TakarKuyApp extends StatefulWidget {
  const TakarKuyApp({super.key});

  @override
  State<TakarKuyApp> createState() => _TakarKuyAppState();
}

class _TakarKuyAppState extends State<TakarKuyApp> {
  // Router disimpan di state agar riwayat halaman tidak hilang saat widget dibangun ulang.
  final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TAKARKUY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
