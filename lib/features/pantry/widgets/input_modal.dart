import 'package:flutter/material.dart';

/// Modal "Tambah bahan" (muncul saat tombol "+ Tambah bahan" ditekan).
/// [onScan] dan [onManual] dipanggil setelah modal tertutup.
Future<void> showAddItemSheet(
  BuildContext context, {
  required VoidCallback onScan,
  required VoidCallback onManual,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (sheetContext) {
      void choose(VoidCallback action) {
        Navigator.pop(sheetContext);
        action();
      }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.centerLeft,
                      child: Text('Batalkan', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Tambah bahan', style: TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tambahkan stok dengan cara yang paling praktis.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                  const SizedBox(height: 16),
                  _option(
                    title: 'Pindai struk belanja',
                    description: 'Unggah struk untuk mendeteksi bahan secara otomatis.',
                    button: _button('Pindai struk', () => choose(onScan), primary: true),
                  ),
                  const SizedBox(height: 16),
                  _option(
                    title: 'Tanpa struk',
                    description: 'Tambah stok bahan secara manual',
                    button: _button('Input manual', () => choose(onManual)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Kartu putih di dalam modal: judul, deskripsi, tombol.
Widget _option({
  required String title,
  required String description,
  required Widget button,
}) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
          const SizedBox(height: 16),
          button,
        ],
      ),
    );

/// Tombol primary (isi #333333) / secondary (putih + garis #A6A6A6), radius 10.
Widget _button(String label, VoidCallback onPressed, {bool primary = false}) {
  final radius = BorderRadius.circular(10);
  return Material(
    color: primary ? const Color(0xFF333333) : const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: radius,
      side: primary ? BorderSide.none : const BorderSide(color: Color(0xFFA6A6A6)),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: radius,
      child: Container(
        constraints: BoxConstraints(minHeight: primary ? 46 : 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 22 / 15,
            fontWeight: FontWeight.w600,
            color: primary ? const Color(0xFFFFFFFF) : const Color(0xFF292929),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    ),
  );
}
