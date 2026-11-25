import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema dasar seluruh aplikasi: AppBar, tombol, input, kartu, chip, dan SnackBar langsung
/// berwarna TAKARKUY tanpa perlu diatur ulang di tiap modul.
abstract final class AppTheme {
  static final ThemeData light = _build();

  static ThemeData _build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      onPrimary: Colors.white,
      secondary: AppColors.lime,
      onSecondary: AppColors.green,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    );
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(64, 48), shape: rounded),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: rounded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.line),
          minimumSize: const Size(64, 48),
          shape: rounded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.soft,
        selectedColor: AppColors.lime,
        side: BorderSide.none,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
