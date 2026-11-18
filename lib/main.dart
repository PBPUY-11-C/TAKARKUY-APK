import 'package:flutter/material.dart';

import 'akun/screens/akun_page.dart';
import 'akun/screens/signup_page.dart';
import 'dashboard/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TAKARKUY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007452),
          primary: const Color(0xFF007452),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      routes: {
        '/login': (_) => const AkunPage(),
        '/signup': (_) => const SignupPage(),
      },
    );
  }
}
