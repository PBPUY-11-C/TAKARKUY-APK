import 'package:flutter/material.dart';

import 'akun/screens/akun_page.dart';
import 'akun/screens/signup_page.dart';

import 'package:takarkuy_apk/screens/menu.dart';

void main() {
  runApp(const TakarKuyApp());
}

/// Akar aplikasi: tema mengikuti warna hijau versi web agar kedua versi terasa satu produk.
class TakarKuyApp extends StatelessWidget {
  const TakarKuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAKARKUY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: TakarKuyColors.green,
          primary: TakarKuyColors.green,
        ),
        scaffoldBackgroundColor: TakarKuyColors.canvas,
      ),
      home: const MenuPage(),
      routes: {
        '/login': (_) => const AkunPage(),
        '/signup': (_) => const SignupPage(),
      },
    );
  }
}
