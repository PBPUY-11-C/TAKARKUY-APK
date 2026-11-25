import 'package:flutter/material.dart';

import '../pantry_page.dart';
import 'pantry_card.dart';

/// Modal "Pencarian stok" yang meluncur dari atas layar.
/// [onEdit] dipanggil setelah modal tertutup saat tombol Edit pada hasil ditekan.
Future<void> showSearchStockModal(
  BuildContext context, {
  required List<PantryItem> items,
  required DateTime today,
  required ValueChanged<PantryItem> onEdit,
  String initialQuery = '',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup pencarian',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, _, _) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: const Color(0xFFF5F5F5),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
              ),
              child: _SearchStockContent(
                items: items,
                today: today,
                initialQuery: initialQuery,
                onClose: () => Navigator.pop(dialogContext),
                onEdit: (item) {
                  Navigator.pop(dialogContext);
                  onEdit(item);
                },
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}

class _SearchStockContent extends StatefulWidget {
  const _SearchStockContent({
    required this.items,
    required this.today,
    required this.initialQuery,
    required this.onClose,
    required this.onEdit,
  });

  final List<PantryItem> items;
  final DateTime today;
  final String initialQuery;
  final VoidCallback onClose;
  final ValueChanged<PantryItem> onEdit;

  @override
  State<_SearchStockContent> createState() => _SearchStockContentState();
}

class _SearchStockContentState extends State<_SearchStockContent> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  String? _expandedId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PantryItem> get _results {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.items
        .where((it) => it.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final results = _results;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Header -------------------------------------------------------
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.onClose,
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
                'Pencarian stok',
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

        // --- Input & Hasil Pencarian --------------------------------------
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu input pencarian + tombol Hapus pencarian
                // Kartu input pencarian
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: (_) => setState(() => _expandedId = null),
                    cursorColor: const Color(0xFF292929),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF292929),
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Cari nama bahan…',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF616161),
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                // Hasil langsung muncul begitu ada teks
                if (query.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${results.length} hasil untuk "$query"',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 19 / 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF292929),
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (results.isEmpty)
                    const Text(
                      'Tidak ada bahan yang cocok.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF292929),
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    )
                  else
                    for (final it in results) ...[
                      PantryCard(
                        name: it.name,
                        quantity: it.quantityLabel,
                        expiry: it.expiryLabel(widget.today),
                        category: it.category,
                        location: it.location,
                        expiryDate: it.expiryDateLabel ?? 'Tanggal belum diketahui',
                        expanded: _expandedId == it.id,
                        onToggle: () => setState(
                          () => _expandedId = _expandedId == it.id ? null : it.id,
                        ),
                        onEdit: () => widget.onEdit(it),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}