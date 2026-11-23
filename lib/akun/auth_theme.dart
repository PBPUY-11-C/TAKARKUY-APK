import 'package:flutter/material.dart';

/// Satu palet untuk seluruh halaman autentikasi pada tema terang dan gelap.
class AuthColors {
  const AuthColors(this.brightness);

  final Brightness brightness;

  bool get dark => brightness == Brightness.dark;
  Color get background =>
      dark ? const Color(0xFF0F1713) : const Color(0xFFE9FFF4);
  Color get card => dark ? const Color(0xFF14251C) : Colors.white;
  Color get field => dark ? const Color(0xFF1B2D23) : const Color(0xFFF3F8F5);
  Color get soft => dark ? field : const Color(0xFFE6F5EC);
  Color get border => dark ? const Color(0xFF294334) : const Color(0xFFDCEBE2);
  Color get text => dark ? const Color(0xFFF2F7F4) : const Color(0xFF10251C);
  Color get muted => dark ? const Color(0xFFA3BBAE) : const Color(0xFF5A6F64);
  Color get accent => dark ? const Color(0xFFD4F45A) : const Color(0xFF007452);
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
