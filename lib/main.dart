import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:takarkuy_apk/recipe_book/screens/recipe_list_page.dart';
=======
import 'dashboard/screens/dashboard_screen.dart';
>>>>>>> db06ffdb9d0d0fd0f1d251ad50d78f86d5e80f78

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4332); // Hijau Dark (Deep Forest Green)

    return MaterialApp(
<<<<<<< HEAD
      title: 'TAKARKUY Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkGreen,
          primary: darkGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const RecipeListPage(),
=======
      debugShowCheckedModeBanner: false,
      title: 'TAKARKUY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
>>>>>>> db06ffdb9d0d0fd0f1d251ad50d78f86d5e80f78
    );
  }
}
