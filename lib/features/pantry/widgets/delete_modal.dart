import 'package:flutter/material.dart';

/// Modal "Hapus bahan" (muncul saat tombol "Hapus" di EditItemPage ditekan).
/// Mengembalikan `true` jika pengguna menekan "Ya, hapus bahan", atau `false`/null jika batal.
Future<bool?> showDeleteItemSheet(
  BuildContext context, {
  required String itemName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header ---------------------------------------------------
            Container(
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(sheetContext, false),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '‹ Kembali',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 24 / 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF292929),
                          leadingDistribution: TextLeadingDistribution.even,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hapus bahan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF292929),
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ],
              ),
            ),

            // --- Konten kartu putih di atas latar #F5F5F5 -----------------
            Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Hapus bahan dari Pantry?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        height: 24 / 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292929),
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292929),
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bahan akan dihapus dari daftar stok. Tindakan ini tidak dapat dibatalkan dalam alur ini.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF292929),
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _button('Ya, hapus bahan', () => Navigator.pop(sheetContext, true)),
                    const SizedBox(height: 12),
                    _button('Batal', () => Navigator.pop(sheetContext, false)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _button(String label, VoidCallback onPressed) {
  final radius = BorderRadius.circular(10);
  return Material(
    color: const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: radius,
      side: const BorderSide(color: Color(0xFFA6A6A6)),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: radius,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 22 / 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF292929),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    ),
  );
}