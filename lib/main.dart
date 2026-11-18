import 'package:flutter/material.dart';

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
    );
  }
}
