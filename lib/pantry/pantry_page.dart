import 'package:flutter/material.dart';

import 'screens/scan_receipt.dart';
import 'screens/edit_item.dart';
import 'screens/input_manual.dart';
import 'widgets/input_modal.dart';
import 'widgets/pantry_card.dart';

/// Halaman Stok Dapur: tombol Tambah bahan, pencarian, filter, urutan, dan daftar kartu stok.
class PantryPage extends StatefulWidget {
  const PantryPage({super.key, this.items, this._today});

  /// Kosongkan untuk memakai data buatan [sampleItems]; isi dengan data dari API nanti.
  final List<PantryItem>? items;
  final DateTime? _today;

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  String _query = '';
  StockFilter _filter = StockFilter.all;
  StockSort _sort = StockSort.expiry;
  String? _expandedId; // id kartu yang sedang terbuka (hanya satu)

  DateTime get _today => widget._today ?? DateTime.now();

  // Salinan yang bisa diubah (edit / hapus), bukan list dari luar.
  late final List<PantryItem> _items = [...(widget.items ?? sampleItems(_today))];

  /// Daftar yang tampil: sudah dicari, difilter, dan diurutkan.
  List<PantryItem> get _visible {
    final q = _query.trim().toLowerCase();
    final today = _today;
    final rows = _items.where((it) {
      if (q.isNotEmpty && !it.name.toLowerCase().contains(q)) return false;
      final days = it.daysLeft(today);
      switch (_filter) {
        case StockFilter.all:
          return true;
        case StockFilter.expiringSoon:
          return days != null && days <= 7;
        case StockFilter.noDate:
          return days == null;
      }
    }).toList();

    int byName(PantryItem a, PantryItem b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    rows.sort(_sort == StockSort.name
        ? byName
        : (a, b) {
            final da = a.expiresOn, db = b.expiresOn;
            if (da == null && db == null) return byName(a, b);
            if (da == null) return 1; // tanpa tanggal di paling bawah
            if (db == null) return -1;
            final c = da.compareTo(db);
            return c != 0 ? c : byName(a, b);
          });
    return rows;
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final items = _visible;
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
            const SizedBox(height: 8),
            _searchField(),
            const SizedBox(height: 8),
            _filterChip(),
            const SizedBox(height: 8),
            _sortButton(),
            const SizedBox(height: 16),
            _countRow(items.length),
            const SizedBox(height: 16),
            // --- Daftar kartu stok ---------------------------------------
            if (items.isEmpty)
              Text('Tidak ada bahan yang cocok.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even))
            else
              for (final it in items) ...[
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
                  onEdit: () => _edit(it),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }

  /// Buka form Edit bahan; terapkan hasilnya (simpan atau hapus) ke daftar.
  Future<void> _edit(PantryItem it) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemPage(
          name: it.name,
          quantity: it.quantity,
          unit: it.unit,
          category: it.category,
          location: it.location,
          expiresOn: it.expiresOn,
        ),
      ),
    );
    if (result == null || !mounted) return; // Batal / Kembali

    if (result['action'] == 'delete') {
      setState(() {
        _items.removeWhere((e) => e.id == it.id);
        if (_expandedId == it.id) _expandedId = null;
      });
      _toast('${it.name} dihapus');
      return;
    }

    final updated = it.edited(
      name: result['name'] as String,
      quantity: (result['quantity'] as num).toDouble(),
      unit: result['unit'] as String,
      category: result['category'] as String,
      location: result['location'] as String,
      expiresOn: result['expiresOn'] as DateTime?,
    );
    setState(() {
      final i = _items.indexWhere((e) => e.id == it.id);
      if (i != -1) _items[i] = updated;
    });
    _toast('${updated.name} diperbarui');
    // TODO: kirim perubahan ke API (PATCH /pantry/items/<id>/).
  }

  // --- Tombol "+ Tambah bahan" -> modal -> form scan / manual -----------------
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

  // --- Cari bahan: tinggi 48, putih, garis #A6A6A6 -------------------------
  Widget _searchField() => Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFA6A6A6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
          cursorColor: const Color(0xFF292929),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'Cari nama bahan…',
            hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF616161), leadingDistribution: TextLeadingDistribution.even),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

  // --- Chip dropdown "Semua stok": #F0F0F0, radius 22 ----------------------
  Widget _filterChip() => PopupMenuButton<StockFilter>(
        tooltip: 'Filter stok',
        initialValue: _filter,
        onSelected: (f) => setState(() => _filter = f),
        itemBuilder: (_) => [
          for (final f in StockFilter.values)
            PopupMenuItem(value: f, child: Text(f.label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even))),
        ],
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFA6A6A6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_filter.label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF292929)),
            ],
          ),
        ),
      );

  // --- Tombol urutan: secondary, tinggi 48 ---------------------------------
  Widget _sortButton() => SizedBox(
        width: double.infinity,
        child: _button('Urut: ${_sort.label}', () => setState(() => _sort = _sort.next)),
      );

  // --- "N bahan · Ketuk bahan untuk detail" ---------------------------------
  Widget _countRow(int n) => Text.rich(
        TextSpan(children: [
          TextSpan(text: '$n', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
          TextSpan(text: ' bahan · Ketuk bahan untuk detail', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
        ]),
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

enum StockFilter {
  all('Semua stok'),
  expiringSoon('Segera kedaluwarsa'),
  noDate('Tanggal belum diketahui');

  const StockFilter(this.label);
  final String label;
}

enum StockSort {
  expiry('Segera kedaluwarsa'),
  name('Nama A–Z');

  const StockSort(this.label);
  final String label;

  StockSort get next => this == expiry ? name : expiry;
}

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

  /// Salinan dengan nilai baru (expiresOn null = tanggal dihapus).
  PantryItem edited({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required String location,
    required DateTime? expiresOn,
  }) =>
      PantryItem(
        id: id,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        location: location,
        expiresOn: expiresOn,
      );

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