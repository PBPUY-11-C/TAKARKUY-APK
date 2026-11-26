import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_theme.dart';

void main() {
  runApp(const TakarKuyApp());
}

/// Menyediakan klien HTTP dan router bersama untuk semua modul.
class TakarKuyApp extends StatefulWidget {
  const TakarKuyApp({super.key, this.client});

  final http.Client? client;

  @override
  State<TakarKuyApp> createState() => _TakarKuyAppState();
}

class _TakarKuyAppState extends State<TakarKuyApp> {
  // Router dan klien disimpan di state agar tidak hilang saat widget dibangun ulang.
  final GoRouter _router = createAppRouter();
  late final ApiClient _api = ApiClient(client: widget.client);

  @override
  void dispose() {
    _router.dispose();
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<ApiClient>.value(value: _api)],
      child: MaterialApp.router(
        title: 'TAKARKUY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
