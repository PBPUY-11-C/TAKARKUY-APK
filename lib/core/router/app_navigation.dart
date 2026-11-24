import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Membuka halaman lewat go_router di aplikasi, atau lewat rute bernama Navigator bila halaman
/// dites sendirian tanpa router; `extra` terbaca di ModalRoute.settings.arguments pada keduanya.
void openRoute(BuildContext context, String path, {Object? extra}) {
  final router = GoRouter.maybeOf(context);
  if (router != null) {
    router.push(path, extra: extra);
  } else {
    Navigator.pushNamed(context, path, arguments: extra);
  }
}

/// Mengganti halaman sekarang dengan halaman lain, dengan aturan router yang sama seperti openRoute.
void replaceRoute(BuildContext context, String path) {
  final router = GoRouter.maybeOf(context);
  if (router != null) {
    router.pushReplacement(path);
  } else {
    Navigator.pushReplacementNamed(context, path);
  }
}
