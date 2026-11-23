import 'package:flutter/material.dart';

// Form Edit bahan
class EditItemPage extends StatefulWidget {
  const EditItemPage({
    super.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.location,
    this.expiresOn,
  });

  final String name;
  final double quantity;
  final String unit;
  final String category;
  final String location;
  final DateTime? expiresOn;

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  static const _units = [
    'gram (g)', 'kilogram (kg)', 'milliliter (ml)', 'liter',
    'buah', 'butir', 'ikat', 'pack / bungkus', 'botol',
  ];
  static const _categories = [
    'Sayur & Buah', 'Daging & Seafood', 'Tahu, Tempe & Kacang',
    'Beras & Karbohidrat', 'Bumbu & Minyak', 'Lainnya',
  ];
  static const _locations = ['Kulkas', 'Freezer', 'Suhu Ruang'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  late final _name = TextEditingController(text: widget.name);
  late final _quantity = TextEditingController(
    text: widget.quantity == widget.quantity.roundToDouble()
        ? widget.quantity.toStringAsFixed(0)
        : widget.quantity.toString(),
  );
  late String _unit = _units.contains(widget.unit) ? widget.unit : _units.first;
  late String _category =
      _categories.contains(widget.category) ? widget.category : _categories.last;
  late String _location =
      _locations.contains(widget.location) ? widget.location : _locations.first;
  late DateTime? _expiresOn = widget.expiresOn;
  late bool _detailsOpen = widget.expiresOn != null;

  String? _nameError;
  String? _quantityError;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? now,
      firstDate: DateTime(2000, 1, 1), // batas backend
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );
    if (picked != null) setState(() => _expiresOn = picked);
  }

  void _save() {
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final quantityText = _quantity.text.trim();
    final quantity = double.tryParse(quantityText.replaceAll(',', '.'));

    String? nameError;
    if (name.isEmpty) {
      nameError = 'Nama bahan wajib diisi.';
    } else if (name.length < 2) {
      nameError = 'Nama bahan terlalu pendek.';
    }
    String? quantityError;
    if (quantityText.isEmpty) {
      quantityError = 'Jumlah wajib diisi.';
    } else if (quantity == null || quantity <= 0) {
      quantityError = 'Jumlah harus berupa angka lebih dari 0.';
    }

    setState(() {
      _nameError = nameError;
      _quantityError = quantityError;
    });
    if (nameError != null || quantityError != null) return;

    Navigator.pop(context, {
      'action': 'save',
      'name': name,
      'quantity': quantity,
      'unit': _unit,
      'category': _category,
      'location': _location,
      'expiresOn': _expiresOn,
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus bahan?', style: TextStyle(fontFamily: 'Inter', fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
        content: Text('"${widget.name}" akan dihapus dari stok.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.pop(context, {'action': 'delete'});
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
                  Text('Edit bahan', style: TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_formCard(), const SizedBox(height: 16), _deleteCard()],
                  ),
                ),
              ),
            ),
            // --- Bar bawah: Batal | Simpan ---------------------------------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border(top: BorderSide(color: Color(0xFFB3B3B3))),
              ),
              child: Row(
                children: [
                  Expanded(child: _button('Batal', () => Navigator.pop(context))),
                  const SizedBox(width: 8),
                  Expanded(child: _button('Simpan', _save, primary: true)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFBFBFBF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Nama bahan *'),
            _textField(_name, TextInputType.text, error: _nameError, onChanged: () => setState(() => _nameError = null)),
            const SizedBox(height: 12),
            _label('Jumlah *'),
            _textField(
              _quantity,
              const TextInputType.numberWithOptions(decimal: true),
              error: _quantityError,
              onChanged: () => setState(() => _quantityError = null),
            ),
            const SizedBox(height: 12),
            _label('Satuan *'),
            _dropdown(_unit, _units, (v) => setState(() => _unit = v)),
            const SizedBox(height: 12),
            _label('Kategori'),
            _dropdown(_category, _categories, (v) => setState(() => _category = v)),
            const SizedBox(height: 12),
            _label('Lokasi simpan'),
            _dropdown(_location, _locations, (v) => setState(() => _location = v)),
            InkWell(
              onTap: () => setState(() => _detailsOpen = !_detailsOpen),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                margin: const EdgeInsets.only(top: 8),
                alignment: Alignment.centerLeft,
                child: Text('Tanggal & detail tambahan (opsional)', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
              ),
            ),
            if (_detailsOpen) ...[
              const SizedBox(height: 8),
              _label('Tanggal kedaluwarsa'),
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
                    _expiresOn == null ? 'Pilih tanggal' : _dateLabel(_expiresOn!),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: _expiresOn == null ? const Color(0xFF616161) : const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
                  ),
                ),
              ),
              if (_expiresOn != null)
                InkWell(
                  onTap: () => setState(() => _expiresOn = null),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.centerLeft,
                    child: Text('Hapus tanggal', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even, decoration: TextDecoration.underline)),
                  ),
                ),
            ],
          ],
        ),
      );

  Widget _deleteCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Penghapusan bahan', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 8),
            Text('Hapus bahan dari stok setelah konfirmasi.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
            const SizedBox(height: 12),
            _button('Hapus', _confirmDelete),
          ],
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
      );

  /// Kotak isian + pesan error
  Widget _textField(
    TextEditingController controller,
    TextInputType type, {
    String? error,
    VoidCallback? onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: error == null ? const Color(0xFFA6A6A6) : const Color(0xFFB3261E)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: type,
              onChanged: (_) => onChanged?.call(),
              cursorColor: const Color(0xFF292929),
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
              decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(error, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w500, color: const Color(0xFFB3261E), leadingDistribution: TextLeadingDistribution.even)),
            ),
        ],
      );

  /// Chip dropdown: #F0F0F0, radius 22, teks di tengah + panah.
  Widget _dropdown(String value, List<String> options, ValueChanged<String> onSelected) =>
      PopupMenuButton<String>(
        initialValue: value,
        onSelected: onSelected,
        itemBuilder: (_) => [
          for (final o in options)
            PopupMenuItem(value: o, child: Text(o, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even))),
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
              Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF292929)),
            ],
          ),
        ),
      );

  /// Tombol primary 
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