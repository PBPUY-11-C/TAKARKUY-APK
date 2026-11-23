import 'package:flutter/material.dart';

import 'screens/scan_receipt.dart';
import 'screens/input_manual.dart';
import 'widgets/input_modal.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Dapur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _addBar(context),
      ),
    );
  }
  // --- App bar: padding 12, gap 4, putih ---------------------------------
  Widget _addBar(BuildContext context) => _button(
        '+ Tambah bahan',
        () => showAddItemSheet(
          context,
          onScan: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const ScanReceiptPage())),
          onManual: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InputManualPage()),
          ),
        ),
        primary: true,
        height: 46,
      );
}

/// Tombol .btn--primary (isi #333333) / .btn--secondary (putih + garis #A6A6A6).
Widget _button(
  String label,
  VoidCallback onPressed, {
  bool primary = false,
  double height = 48,
}) {
  final radius = BorderRadius.circular(10);
  return Material(
    color: primary ? const Color(0xFF333333) : const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: radius,
      side: primary
          ? BorderSide.none
          : const BorderSide(color: Color(0xFFA6A6A6)),
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
            color: primary ? const Color(0xFFFFFFFF) : const Color(0xFF292929),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    ),
  );
}