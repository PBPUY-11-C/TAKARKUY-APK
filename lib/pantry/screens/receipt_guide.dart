import 'package:flutter/material.dart';

/// Halaman Panduan Foto Struk (contoh struk yang dapat & tidak dapat dipindai).
class ReceiptGuidePage extends StatelessWidget {
  const ReceiptGuidePage({
    super.key,
    this.invalidReceiptAsset = 'assets/images/struk_tidak_valid.png',
    this.validReceiptAsset = 'assets/images/struk_valid.png',
  });

  final String invalidReceiptAsset;
  final String validReceiptAsset;

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
                      child: const Text(
                        '‹ Kembali ke pindai',
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
                    'Panduan Foto Struk',
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

            // --- Konten dapat digulir -------------------------------------
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _guideCard(
                        title: 'Tidak Dapat Dipindai dengan Benar',
                        imageAsset: invalidReceiptAsset,
                        description:
                            'Bagian struk memiliki dua baris teks. Hanya baris kedua yang terbaca, sehingga hasilnya akan tidak sesuai.',
                      ),
                      const SizedBox(height: 16),
                      _guideCard(
                        title: 'Dapat Dipindai',
                        imageAsset: validReceiptAsset,
                        description:
                            'Setiap item berada dalam satu baris teks dengan nama dan jumlah yang jelas sehingga dapat terbaca dengan benar.',
                      ),
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

  Widget _guideCard({
    required String title,
    required String imageAsset,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBFBFBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF292929),
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: 200,
                color: const Color(0xFFF0F0F0),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Gambar contoh struk belum tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF616161),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF292929),
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ],
      ),
    );
  }
}