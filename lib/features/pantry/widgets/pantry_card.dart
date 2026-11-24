import 'package:flutter/material.dart';

/// Kartu stok: ringkasan selalu tampil, detail (panel #F0F0F0) muncul saat diketuk.
class PantryCard extends StatelessWidget {
  const PantryCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.expiry,
    required this.category,
    required this.location,
    required this.expiryDate,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
  });

  final String name; // "Daging Ayam"
  final String quantity; // "Jumlah: 620 gram (g)"
  final String expiry; // "1 hari lagi"
  final String category; // "Daging & Seafood"
  final String location; // "Kulkas"
  final String expiryDate; // "31 Okt 2026"
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(6);
    return Material(
      color: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: Color(0xFFBFBFBF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: expanded,
              child: InkWell(
                onTap: onToggle,
                borderRadius: radius,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontFamily: 'Inter', fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                    const SizedBox(height: 4),
                    Text(quantity, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                    const SizedBox(height: 4),
                    Text(expiry, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.topCenter,
              child: expanded ? _detail() : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        color: Color(0xFFF0F0F0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text(location, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text(expiryDate,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            _button('Ubah', onEdit),
          ],
        ),
      );
}

/// Tombol secondary: putih + garis #A6A6A6, radius 10.
Widget _button(
  String label,
  VoidCallback onPressed, {
  double height = 48,
}) {
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
        constraints: BoxConstraints(minHeight: height),
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
            color: const Color(0xFF292929),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    ),
  );
}