import 'package:flutter/material.dart';
import 'package:takarkuy_apk/recipe_book/screens/recipe_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4332); // Hijau Dark (Deep Forest Green)

    return MaterialApp(
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
    );
  }
}
