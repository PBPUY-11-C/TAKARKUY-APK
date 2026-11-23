import 'package:flutter/material.dart';
import 'package:takarkuy_apk/pantry/screens/receipt_guide.dart';

/// Layar "Pindai struk" (Tambah bahan lewat foto struk).
/// Saat disimpan, layar menutup dan mengembalikan Map:
/// {source: 'ocr', items: [{name, quantity, unit, starting_on}]}  (format sama dengan API pantry/items/).
class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPage();
}

class _ReceiptRow {
  final name = TextEditingController();
  final quantity = TextEditingController();
  var unit = ('gram (g)', 'g');
  String? error;

  void dispose() {
    name.dispose();
    quantity.dispose();
  }
}

class _ScanReceiptPage extends State<ScanReceiptPage> {
  static const _units = [
    ('gram (g)', 'g'),
    ('kilogram (kg)', 'kg'),
    ('milliliter (ml)', 'ml'),
    ('liter', 'liter'),
    ('buah', 'buah'),
    ('butir', 'butir'),
    ('ikat', 'ikat'),
    ('pack / bungkus', 'pack'),
    ('botol', 'botol'),
  ];

  String? _receiptName; // nama file struk yang dipilih (null = belum ada)
  DateTime? _purchasedOn;
  final List<_ReceiptRow> _rows = [];

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _dateLabel(DateTime d) => '${_two(d.month)}/${_two(d.day)}/${d.year}'; // mm/dd/yyyy
  String _dateIso(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _pickReceipt() async {
    // TODO: pilih foto (mis. paket image_picker), kirim ke POST /pantry/ocr-fallback/,
    // lalu isi _receiptName dan _rows dari respons {"items": [...]}.
    _toast('Unggah struk belum tersambung ke OCR');
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedOn ?? now,
      firstDate: DateTime(2000, 1, 1), // batas backend
      lastDate: now, // backend menolak tanggal masa depan
    );
    if (picked != null) setState(() => _purchasedOn = picked);
  }

  void _showGuide() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ReceiptGuidePage()),
    );
  }

  void _save() {
    var ok = true;
    final items = <Map<String, dynamic>>[];
    for (final r in _rows) {
      final name = r.name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final q = double.tryParse(r.quantity.text.trim().replaceAll(',', '.'));
      r.error = (name.length < 2 || q == null || q <= 0)
          ? 'Isi nama (min. 2 huruf) dan jumlah lebih dari 0.'
          : null;
      if (r.error != null) {
        ok = false;
      } else {
        items.add({
          'name': name,
          'quantity': q,
          'unit': r.unit.$2,
          'starting_on': _purchasedOn == null ? null : _dateIso(_purchasedOn!),
        });
      }
    }
    setState(() {});
    if (ok && items.isNotEmpty) Navigator.pop(context, {'source': 'ocr', 'items': items});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
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
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.centerLeft,
                      child: Text('‹ Kembali', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Pindai struk', style: TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                ],
              ),
            ),
            // --- Isi (dapat digulir) -----------------------------------------
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_card(), if (_rows.isNotEmpty) ...[const SizedBox(height: 16), _saveButton()]],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFBFBFBF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pindai Struk Belanja Kasir / Pasar', style: TextStyle(fontFamily: 'Inter', fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text('Unggah struk untuk mendeteksi bahan secara otomatis.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 12),
            Text('Pindai & Periksa', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            // Status pemindaian
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF0F0F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_receiptName == null ? 'Belum ada struk dipilih' : 'Struk dipilih', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                  const SizedBox(height: 8),
                  Text(_receiptName ?? 'Pilih foto struk yang jelas untuk mulai memindai.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                  const SizedBox(height: 8),
                  Text('${_rows.length} Item Terdeteksi', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                ],
              ),
            ),
            InkWell(
              onTap: _showGuide,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                margin: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.centerLeft,
                child: Text('Panduan foto struk yang bisa dipindai', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
              ),
            ),
            _button('Unggah Struk Belanja', _pickReceipt, primary: true),
            const SizedBox(height: 16),
            _label('Tanggal belanja / mulai simpan (opsional)'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA6A6A6)),
                ),
                child: Text(
                  _purchasedOn == null ? 'mm/dd/yyyy' : _dateLabel(_purchasedOn!),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: _purchasedOn == null ? const Color(0xFF616161) : const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Pratinjau / status unggahan
            Container(
              constraints: const BoxConstraints(minHeight: 86),
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF0F0F0),
              child: Text(
                _receiptName == null ? 'Belum ada struk yang diunggah.' : _receiptName!,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
              ),
            ),
            const SizedBox(height: 16),
            Text('Periksa kembali nama dan jumlah bahan.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text('Baris siap diperiksa', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text('${_rows.length} bahan', style: TextStyle(fontFamily: 'Inter', fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 12),
            for (var i = 0; i < _rows.length; i++) ...[_rowCard(i), const SizedBox(height: 12)],
            _button('+ Tambah Baris', () => setState(() => _rows.add(_ReceiptRow()))),
          ],
        ),
      );

  /// Satu baris bahan hasil pindai (dapat diedit atau dihapus).
  Widget _rowCard(int i) {
    final r = _rows[i];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: r.error == null ? const Color(0xFFBFBFBF) : const Color(0xFFB3261E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Nama bahan'),
          _field(r.name, TextInputType.text),
          const SizedBox(height: 12),
          _label('Jumlah'),
          _field(r.quantity, const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 12),
          _label('Satuan'),
          PopupMenuButton<int>(
            initialValue: _units.indexOf(r.unit),
            onSelected: (k) => setState(() => r.unit = _units[k]),
            itemBuilder: (_) => [
              for (var k = 0; k < _units.length; k++)
                PopupMenuItem(value: k, child: Text(_units[k].$1, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even))),
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
                  Text(r.unit.$1, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF292929)),
                ],
              ),
            ),
          ),
          if (r.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(r.error!, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w500, color: const Color(0xFFB3261E), leadingDistribution: TextLeadingDistribution.even)),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => setState(() => _rows.removeAt(i).dispose()),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                alignment: Alignment.centerLeft,
                child: Text('Hapus baris', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() => _button('+ Tambah ke Pantry', _save, primary: true);

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
      );

  Widget _field(TextEditingController c, TextInputType type) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFA6A6A6)),
        ),
        child: TextField(
          controller: c,
          keyboardType: type,
          cursorColor: const Color(0xFF292929),
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
          decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14)),
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
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600, color: primary ? const Color(0xFFFFFFFF) : const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
        ),
      ),
    );
  }
}