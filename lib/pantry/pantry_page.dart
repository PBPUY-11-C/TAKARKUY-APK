import 'package:flutter/material.dart';

import 'screens/scan_receipt.dart';
import 'screens/input_manual.dart';
import 'widgets/input_modal.dart';
import 'widgets/pantry_card.dart';

/// Halaman Stok Dapur
class PantryPage extends StatefulWidget {
  const PantryPage({super.key, this.items, this._today});

  /// Kosongkan untuk memakai data buatan [sampleItems]; isi dengan data dari API nanti.
  final List<PantryItem>? items;
  final DateTime? _today;

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  String? _expandedId;

  DateTime get _today => widget._today ?? DateTime.now();

  late final List<PantryItem> _items = widget.items ?? sampleItems(_today);

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Stok Dapur', style: TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _addBar(),
            const SizedBox(height: 16),
            
            // --- Daftar kartu stok ---------------------------------------
            for (final it in _items) ...[
              PantryCard(
                name: it.name,
                quantity: it.quantityLabel,
                expiry: it.expiryLabel(_today),
                category: it.category,
                location: it.location,
                expiryDate: it.expiryDateLabel ?? 'Tanggal belum diketahui',
                expanded: _expandedId == it.id,
                onToggle: () => setState(
                    () => _expandedId = _expandedId == it.id ? null : it.id),
                onEdit: () => _toast('Ubah ${it.name}'),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // --- Tombol Tambah -> modal -> form scan / manual -----------------
  Widget _addBar() => _button(
        '+ Tambah bahan',
        () => showAddItemSheet(
          context,
          onScan: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanReceiptPage()),
          ),
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
      side: primary ? BorderSide.none : const BorderSide(color: Color(0xFFA6A6A6)),
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

// ---------------------------------------------------------------------------
// Model & data buatan
// ---------------------------------------------------------------------------

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.location,
    this.unit = 'gram (g)',
    this.expiresOn,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final String location;
  final DateTime? expiresOn; // null = tanggal belum diketahui

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// "Jumlah: 620 gram (g)"
  String get quantityLabel {
    final q = quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toString();
    return 'Jumlah: $q $unit';
  }

  /// Selisih hari kalender (null jika tanggal belum diketahui).
  int? daysLeft(DateTime today) {
    final d = expiresOn;
    if (d == null) return null;
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(d.year, d.month, d.day);
    return b.difference(a).inDays;
  }

  /// "1 hari lagi" / "Hari ini" / "Kedaluwarsa 2 hari lalu" / "Tanggal belum diketahui"
  String expiryLabel(DateTime today) {
    final n = daysLeft(today);
    if (n == null) return 'Tanggal belum diketahui';
    if (n < 0) return 'Kedaluwarsa ${-n} hari lalu';
    if (n == 0) return 'Hari ini';
    return '$n hari lagi';
  }

  /// "31 Okt 2026"
  String? get expiryDateLabel {
    final d = expiresOn;
    if (d == null) return null;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }
}

/// Data buatan (angka dari frame Figma), kedaluwarsa dihitung dari [today].
/// Ganti dengan data dari API Modul 2 kalau sudah tersambung.
List<PantryItem> sampleItems(DateTime today) {
  DateTime? inDays(int? n) => n == null
      ? null
      : DateTime(today.year, today.month, today.day).add(Duration(days: n));
  PantryItem i(String id, String name, double q, String cat, String loc, int? days) =>
      PantryItem(
        id: id,
        name: name,
        quantity: q,
        category: cat,
        location: loc,
        expiresOn: inDays(days),
      );
  return [
    i('1', 'Daging Ayam', 620, 'Daging & Seafood', 'Kulkas', 1),
    i('2', 'Jagung Manis', 120, 'Sayur & Buah', 'Kulkas', 60),
    i('3', 'Bihun', 300, 'Beras & Karbohidrat', 'Suhu Ruang', null),
    i('4', 'Garam', 20, 'Bumbu & Minyak', 'Suhu Ruang', null),
  ];
}