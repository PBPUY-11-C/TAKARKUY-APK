import 'package:flutter/material.dart';

/// Layar "Input manual" (Tambah bahan tanpa struk).
/// Saat valid, layar menutup dan mengembalikan Map:
/// {name, category (kode backend), quantity (double), unit (kode backend)}.
class InputManualPage extends StatefulWidget {
  const InputManualPage({super.key});

  @override
  State<InputManualPage> createState() => _InputManualPageState();
}

class _InputManualPageState extends State<InputManualPage> {
  // (label tampil, kode di backend Django PantryItem)
  static const _categories = [
    ('Sayur & Buah', 'sayur_buah'),
    ('Daging & Seafood', 'daging_seafood'),
    ('Tahu, Tempe & Kacang', 'tahu_tempe_kacang'),
    ('Beras & Karbohidrat', 'beras_karbohidrat'),
    ('Bumbu & Minyak', 'bumbu_minyak'),
    ('Lainnya', 'lainnya'),
  ];
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

  final _name = TextEditingController();
  final _quantity = TextEditingController();
  var _category = _categories.first;
  var _unit = _units.first;
  String? _nameError;
  String? _quantityError;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final quantityText = _quantity.text.trim();
    final quantity = double.tryParse(quantityText.replaceAll(',', '.'));

    String? nameError;
    if (name.isEmpty) {
      nameError = 'Nama bahan makanan wajib diisi.';
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
      'name': name,
      'category': _category.$2,
      'quantity': quantity,
      'unit': _unit.$2,
    });
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
                  Text('Input manual', style: TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
                ],
              ),
            ),
            // --- Form -----------------------------------------------------
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFBFBF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('* Wajib diisi · Tanpa struk', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w400, color: const Color(0xFF616161), leadingDistribution: TextLeadingDistribution.even)),
                            const SizedBox(height: 12),
                            _label('Nama Bahan Makanan *'),
                            _textField(
                              _name,
                              TextInputType.text,
                              error: _nameError,
                              onChanged: () => setState(() => _nameError = null),
                            ),
                            const SizedBox(height: 16),
                            _label('Kategori *'),
                            _dropdown(
                              value: _category.$1,
                              options: [for (final c in _categories) c.$1],
                              onSelected: (i) => setState(() => _category = _categories[i]),
                            ),
                            const SizedBox(height: 16),
                            _label('Jumlah *'),
                            _textField(
                              _quantity,
                              const TextInputType.numberWithOptions(decimal: true),
                              error: _quantityError,
                              onChanged: () => setState(() => _quantityError = null),
                            ),
                            const SizedBox(height: 16),
                            _label('Satuan *'),
                            _dropdown(
                              value: _unit.$1,
                              options: [for (final u in _units) u.$1],
                              onSelected: (i) => setState(() => _unit = _units[i]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tombol di tengah (tidak menempel di bawah layar).
                      _primaryButton('+ Tambah ke Pantry', _submit),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 19 / 13, fontWeight: FontWeight.w600, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even)),
      );

  /// Kotak isian + pesan error tepat di bawahnya (border berubah merah saat error).
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
              border: Border.all(
                color: error == null ? const Color(0xFFA6A6A6) : const Color(0xFFB3261E),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: type,
              onChanged: (_) => onChanged?.call(),
              cursorColor: const Color(0xFF292929),
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
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
  Widget _dropdown({
    required String value,
    required List<String> options,
    required ValueChanged<int> onSelected,
  }) =>
      PopupMenuButton<int>(
        initialValue: options.indexOf(value),
        onSelected: onSelected,
        itemBuilder: (_) => [
          for (var i = 0; i < options.length; i++)
            PopupMenuItem(value: i, child: Text(options[i], style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: const Color(0xFF292929), leadingDistribution: TextLeadingDistribution.even))),
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

  Widget _primaryButton(String label, VoidCallback onPressed) {
    final radius = BorderRadius.circular(10);
    return Material(
      color: const Color(0xFF333333),
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.center,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600, color: const Color(0xFFFFFFFF), leadingDistribution: TextLeadingDistribution.even)),
        ),
      ),
    );
  }
}