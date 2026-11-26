import 'package:flutter/material.dart';

/// Palet halaman Planner, disamakan dengan `.planner-page` di apps/planner/static/planner/planner.css.
/// Header dan tema dasar tetap memakai AppColors; warna di sini khusus isi halaman Planner.
abstract final class PlannerColors {
  static const background = Color(0xFFF6F8FC);
  static const green = Color(0xFF007A58);
  static const greenDark = Color(0xFF006747);
  static const greenSoft = Color(0xFFE4F7EC);
  static const greenText = Color(0xFF0F5C43);
  static const ink = Color(0xFF172235);
  static const muted = Color(0xFF5D6874);
  static const line = Color(0xFFE6ECF2);
  static const field = Color(0xFFD5DEE8);
  static const soft = Color(0xFFF1F5FC);
  static const warn = Color(0xFF7A3F0A);
  static const warnSoft = Color(0xFFFFF3E0);
  static const danger = Color(0xFFB42318);

  /// Warna cincin gizi web: energi, protein, karbohidrat, lemak.
  static const rings = [Color(0xFF4F86B8), Color(0xFF2F9E62), Color(0xFFC98A1B), Color(0xFFD0564F)];
  static const ringTracks = [Color(0xFFDCE8F3), Color(0xFFD8EFE2), Color(0xFFF6E8CC), Color(0xFFF7DCDA)];
}
