import 'package:flutter/material.dart';

import '../pantry_page.dart';

/// Modal "Filter Kedaluwarsa" (muncul saat chip "Semua stok" ditekan).
/// Mengembalikan [StockFilter] yang dipilih, atau null jika dibatalkan.
Future<StockFilter?> showExpiryFilterSheet(
  BuildContext context, {
  required StockFilter currentFilter,
  required int Function(StockFilter filter) countFor,
}) {
  return showModalBottomSheet<StockFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (sheetContext) {
      var selected = currentFilter;
      var showNotes = false;

      return StatefulBuilder(
        builder: (context, setModalState) {
          final count = countFor(selected);

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header (sama seperti input_modal) --------------------
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
                          child: const Text(
                            'Batalkan',
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
                        'Filter Kedaluwarsa',
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

                // --- Konten kartu putih di atas latar #F5F5F5 -------------
                Container(
                  color: const Color(0xFFF5F5F5),
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFBFBF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Stok Pantry Saat Ini',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            height: 24 / 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF292929),
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Perkiraan kedaluwarsa mengikuti lokasi simpan dan tanggal belanja.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF292929),
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => setModalState(() => showNotes = !showNotes),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Catatan penyimpanan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF292929),
                                leadingDistribution: TextLeadingDistribution.even,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (showNotes) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '• Kulkas menjaga kesegaran sayur, buah, dan protein lebih lama.\n'
                              '• Freezer cocok untuk penyimpanan daging dan bahan beku jangka panjang.\n'
                              '• Suhu ruang cocok untuk bahan kering, beras, dan bumbu.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                height: 19 / 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF292929),
                                leadingDistribution: TextLeadingDistribution.even,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),

                        // --- Dropdown pilih filter ------------------------
                        PopupMenuButton<StockFilter>(
                          tooltip: 'Pilih filter kedaluwarsa',
                          initialValue: selected,
                          onSelected: (f) => setModalState(() => selected = f),
                          itemBuilder: (_) => [
                            for (final f in StockFilter.values)
                              PopupMenuItem(
                                value: f,
                                child: Text(
                                  f.label,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    height: 20 / 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF292929),
                                    leadingDistribution: TextLeadingDistribution.even,
                                  ),
                                ),
                              ),
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
                                Flexible(
                                  child: Text(
                                    selected.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      height: 20 / 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF292929),
                                      leadingDistribution: TextLeadingDistribution.even,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF292929)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- Status hasil filter --------------------------
                        if (count == 0) ...[
                          const Text(
                            'Tidak ada bahan pada filter ini.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              height: 19 / 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF292929),
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _emptyMessage(selected),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF292929),
                                leadingDistribution: TextLeadingDistribution.even,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _primaryButton(
                            'Lihat semua stok',
                            () => Navigator.pop(sheetContext, StockFilter.all),
                          ),
                        ] else ...[
                          Text(
                            '$count bahan ditemukan pada filter ini.',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              height: 19 / 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF292929),
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _primaryButton(
                            selected == StockFilter.all ? 'Lihat semua stok' : 'Terapkan filter',
                            () => Navigator.pop(sheetContext, selected),
                          ),
                        ],
                        const SizedBox(height: 8),

                        // --- Reset filter ---------------------------------
                        InkWell(
                          onTap: () => Navigator.pop(sheetContext, StockFilter.all),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Reset filter',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF292929),
                                leadingDistribution: TextLeadingDistribution.even,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String _emptyMessage(StockFilter filter) {
  switch (filter) {
    case StockFilter.all:
      return 'Belum ada bahan di stok pantry.';
    case StockFilter.expiringSoon:
      return 'Tidak ada bahan yang segera kedaluwarsa.';
    case StockFilter.expired:
      return 'Tidak ada bahan yang sudah kedaluwarsa.';
    case StockFilter.noDate:
      return 'Tidak ada bahan tanpa tanggal kedaluwarsa.';
  }
}

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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 22 / 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    ),
  );
}