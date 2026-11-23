import 'package:flutter/material.dart';

/// Palet autentikasi bersama, dengan variasi terang sesuai desain tiap halaman.
class AuthColors {
  const AuthColors(
    this.brightness, {
    this.lightBackground = const Color(0xFFF2F8F4),
    this.lightField = const Color(0xFFE6F5EC),
    this.lightAccent = const Color(0xFF0F3D2E),
  });

  final Brightness brightness;
  final Color lightBackground, lightField, lightAccent;

  bool get dark => brightness == Brightness.dark;
  Color get background => dark ? const Color(0xFF0F1713) : lightBackground;
  Color get card => dark ? const Color(0xFF14251C) : Colors.white;
  Color get field => dark ? const Color(0xFF1B2D23) : lightField;
  Color get soft => dark ? field : const Color(0xFFE6F5EC);
  Color get border => dark ? const Color(0xFF294334) : const Color(0xFFDCEBE2);
  Color get text => dark ? const Color(0xFFF2F7F4) : const Color(0xFF10251C);
  Color get muted => dark ? const Color(0xFFA3BBAE) : const Color(0xFF5A6F64);
  Color get accent => dark ? const Color(0xFFD4F45A) : lightAccent;
  Color get actionText => dark ? const Color(0xFF10251C) : Colors.white;
  Color get error => dark ? const Color(0xFFF29D95) : const Color(0xFFB42318);
}

ThemeData authTheme(ThemeData base, Brightness brightness) => base.copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F3D2E),
    brightness: brightness,
  ),
);

/// Menjaga pilihan tema ketika berpindah antarhalaman autentikasi.
Brightness? authBrightnessFromRoute(BuildContext context) {
  final arguments = ModalRoute.of(context)?.settings.arguments;
  if (arguments is Map && arguments['brightness'] is Brightness) {
    return arguments['brightness'] as Brightness;
  }
  return null;
}
