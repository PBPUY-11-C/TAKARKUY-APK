import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_theme.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';

void main() {
  runApp(const TakarKuyApp());
}

/// Akar aplikasi: token auth, klien API, tema, dan router dibuat sekali untuk semua modul.
class TakarKuyApp extends StatefulWidget {
  const TakarKuyApp({
    super.key,
    this.client,
    this.initialToken,
    this.initialUsername,
  });

  final http.Client? client;
  final String? initialToken;
  final String? initialUsername;

  @override
  State<TakarKuyApp> createState() => _TakarKuyAppState();
}

class _TakarKuyAppState extends State<TakarKuyApp> {
  // AuthState/router dibuat sekali agar token dan route guard tidak hilang saat rebuild.
  late final ApiClient _api = ApiClient(client: widget.client);
  late final AuthState _auth = AuthState(
    _api,
    token: widget.initialToken,
    username: widget.initialUsername,
  );
  late final GoRouter _router = createAppRouter(_auth);

  @override
  void initState() {
    super.initState();
    if (widget.initialToken == null) _auth.restoreSession();
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _api),
        ChangeNotifierProvider<AuthState>.value(value: _auth),
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
