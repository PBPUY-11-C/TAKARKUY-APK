import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/pantry/pantry_page.dart';

/// Layar setinggi ponsel (390 x 844) supaya daftar dan tombol muat di layar tes.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> openPage(WidgetTester tester, {PantryPage? page}) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(MaterialApp(home: page ?? const PantryPage()));
}

/// Teks hitungan "N bahan · Ketuk bahan untuk detail" (Text.rich, jadi perlu findRichText).
Finder countText(int n) =>
    find.text('$n bahan · Ketuk bahan untuk detail', findRichText: true);

void main() {
  testWidgets('halaman Pantry menampilkan judul Stok Dapur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantryPage()));

    expect(find.text('Stok Dapur'), findsOneWidget);
  });

  group('tampilan awal', () {
    testWidgets('menampilkan elemen utama sesuai desain', (tester) async {
      await openPage(tester);

      expect(find.text('Stok Dapur'), findsOneWidget);
      expect(find.text('+ Tambah bahan'), findsOneWidget);
      expect(find.text('Cari nama bahan…'), findsOneWidget);
      expect(find.text('Semua stok'), findsOneWidget);
      expect(find.text('Urut: Segera kedaluwarsa'), findsOneWidget);
    });

    testWidgets('memakai data contoh bila items tidak diberikan', (tester) async {
      await openPage(tester);

      expect(countText(4), findsOneWidget);
      expect(find.text('Daging Ayam'), findsOneWidget);
      expect(find.text('Jumlah: 620 gram (g)'), findsOneWidget);
    });

    testWidgets('urutan awal: yang paling cepat kedaluwarsa di atas', (tester) async {
      await openPage(tester);

      final ayam = tester.getTopLeft(find.text('Daging Ayam')).dy;
      final jagung = tester.getTopLeft(find.text('Jagung Manis')).dy;
      expect(ayam, lessThan(jagung)); // sama-sama 1 hari lagi, urut nama
    });
  });

  group('label kedaluwarsa', () {
    testWidgets('hari ini, lewat, mendatang, dan tanpa tanggal', (tester) async {
      final today = DateTime(2026, 11, 23);
      await openPage(
        tester,
        page: PantryPage(
          today: today,
          items: [
            PantryItem(id: '1', name: 'Susu', quantity: 1.5, unit: 'liter', category: 'Lainnya', location: 'Kulkas', expiresOn: DateTime(2026, 11, 23)),
            PantryItem(id: '2', name: 'Roti', quantity: 2, unit: 'buah', category: 'Lainnya', location: 'Suhu Ruang', expiresOn: DateTime(2026, 11, 21)),
            PantryItem(id: '3', name: 'Keju', quantity: 100, category: 'Lainnya', location: 'Kulkas', expiresOn: DateTime(2026, 11, 26)),
            const PantryItem(id: '4', name: 'Garam', quantity: 20, category: 'Bumbu & Minyak', location: 'Suhu Ruang'),
          ],
        ),
      );

      expect(find.text('Hari ini'), findsOneWidget);
      expect(find.text('Kedaluwarsa 2 hari lalu'), findsOneWidget);
      expect(find.text('3 hari lagi'), findsOneWidget);
      expect(find.text('Tanggal belum diketahui'), findsOneWidget);
      expect(find.text('Jumlah: 1.5 liter'), findsOneWidget); // desimal tetap tampil
      expect(find.text('Jumlah: 100 gram (g)'), findsOneWidget); // bulat tanpa .0
    });
  });

  group('pencarian', () {
    testWidgets('menyaring daftar berdasarkan nama', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byType(TextField), 'ayam');
      await tester.pump();

      expect(find.text('Daging Ayam'), findsOneWidget);
      expect(find.text('Udang'), findsNothing);
      expect(countText(1), findsOneWidget);
    });

    testWidgets('tidak peka huruf besar/kecil', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byType(TextField), 'BIHUN');
      await tester.pump();

      expect(find.text('Bihun'), findsOneWidget);
      expect(countText(1), findsOneWidget);
    });

    testWidgets('tanpa hasil: tampil pesan kosong dan hitungan 0', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('Tidak ada bahan yang cocok.'), findsOneWidget);
      expect(countText(0), findsOneWidget);
    });
  });

  group('filter dan urutan', () {
    testWidgets('filter "Segera kedaluwarsa" hanya menampilkan <= 7 hari', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('Semua stok'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Segera kedaluwarsa').last);
      await tester.pumpAndSettle();

      expect(countText(1), findsOneWidget);
      expect(find.text('Telur Ayam'), findsNothing); // 30 hari lagi
    });

    testWidgets('tombol urut berganti ke Nama A–Z lalu kembali', (tester) async {
      await openPage(tester);

      await tester.tap(find.textContaining('Urut:'));
      await tester.pump();
      expect(find.text('Urut: Nama A–Z'), findsOneWidget);

      final bihun = tester.getTopLeft(find.text('Bihun')).dy;
      final dagingAyam = tester.getTopLeft(find.text('Daging Ayam')).dy;
      expect(bihun, lessThan(dagingAyam)); // A sebelum B

      await tester.tap(find.textContaining('Urut:'));
      await tester.pump();
      expect(find.text('Urut: Segera kedaluwarsa'), findsOneWidget);
    });
  });

  group('kartu stok', () {
    testWidgets('diketuk membuka detail, diketuk lagi menutup', (tester) async {
      await openPage(tester);
      expect(find.text('Ubah'), findsNothing);

      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      expect(find.text('Daging & Seafood'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);
      expect(find.text('Ubah'), findsOneWidget);

      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      expect(find.text('Ubah'), findsNothing);
    });

    testWidgets('hanya satu kartu yang terbuka pada satu waktu', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jagung Manis'));
      await tester.pumpAndSettle();

      expect(find.text('Ubah'), findsOneWidget);
      expect(find.text('Sayur & Buah'), findsOneWidget); // kategori Jagung Manis
    });

    testWidgets('tombol Ubah membuka form Edit bahan berisi data kartu', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();

      expect(find.text('Edit bahan'), findsOneWidget);
      expect(find.text('Daging Ayam'), findsOneWidget); // isi kolom nama
      expect(find.text('620'), findsOneWidget); // isi kolom jumlah
    });
  });

  group('tambah bahan', () {
    testWidgets('tombol + Tambah bahan membuka modal dengan dua pilihan', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('+ Tambah bahan'));
      await tester.pumpAndSettle();

      expect(find.text('Tambahkan stok dengan cara yang paling praktis.'), findsOneWidget);
      expect(find.text('Pindai struk belanja'), findsOneWidget);
      expect(find.text('Tanpa struk'), findsOneWidget);
      expect(find.text('Pindai struk'), findsOneWidget);
      expect(find.text('Input manual'), findsOneWidget);
    });

    testWidgets('Input manual menutup modal dan membuka form manual', (tester) async {
      await openPage(tester);
      await tester.tap(find.text('+ Tambah bahan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Input manual'));
      await tester.pumpAndSettle();

      expect(find.text('Nama Bahan Makanan *'), findsOneWidget);
      expect(find.text('Tambahkan stok dengan cara yang paling praktis.'), findsNothing);
    });

    testWidgets('Pindai struk menutup modal dan membuka form scan', (tester) async {
      await openPage(tester);
      await tester.tap(find.text('+ Tambah bahan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pindai struk'));
      await tester.pumpAndSettle();

      expect(find.text('Pindai Struk Belanja Kasir / Pasar'), findsOneWidget);
    });
  });

  group('edit dan hapus dari halaman stok', () {
    Future<void> openEdit(WidgetTester tester, String name) async {
      await openPage(tester);
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();
    }

    testWidgets('Simpan memperbarui kartu dan menampilkan toast', (tester) async {
      await openEdit(tester, 'Daging Ayam');

      await tester.enterText(find.byType(TextField).at(0), 'Dada Ayam');
      await tester.enterText(find.byType(TextField).at(1), '500');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Edit bahan'), findsNothing); // kembali ke daftar
      expect(find.text('Dada Ayam'), findsOneWidget);
      expect(find.text('Daging Ayam'), findsNothing);
      expect(find.text('Jumlah: 500 gram (g)'), findsOneWidget);
      expect(find.text('Dada Ayam diperbarui'), findsOneWidget);
    });

    testWidgets('Batal tidak mengubah kartu', (tester) async {
      await openEdit(tester, 'Daging Ayam');

      await tester.enterText(find.byType(TextField).at(0), 'Nama Lain');
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Daging Ayam'), findsOneWidget);
      expect(find.text('Nama Lain'), findsNothing);
    });

    testWidgets('Hapus + konfirmasi mengeluarkan bahan dari daftar', (tester) async {
      await openEdit(tester, 'Daging Ayam');

      await tester.ensureVisible(find.text('Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus').last); // tombol di dialog
      await tester.pumpAndSettle();

      expect(find.text('Daging Ayam'), findsNothing);
      expect(countText(3), findsOneWidget);
      expect(find.text('Daging Ayam dihapus'), findsOneWidget);
    });
  });
}