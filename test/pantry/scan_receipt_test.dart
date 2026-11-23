import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan nama paket dengan `name:` di pubspec.yaml proyek Anda.
// Kalau file diganti nama jadi scan_receipt.dart, ubah import dan nama kelas di bawah.
import 'package:takarkuy_apk/pantry/screens/scan_receipt.dart';

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Widget directPage() => const MaterialApp(home: ScanReceiptPage());

Widget hostedPage(void Function(Object? result) onResult) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async => onResult(await Navigator.push<Object?>(
                context,
                MaterialPageRoute(builder: (_) => const ScanReceiptPage()),
              )),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

/// Gulir sampai terlihat lalu ketuk.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

String two(int n) => n.toString().padLeft(2, '0');

void main() {
  group('tampilan awal', () {
    testWidgets('menampilkan keadaan kosong sesuai desain', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      expect(find.text('Pindai struk'), findsOneWidget);
      expect(find.text('Pindai Struk Belanja Kasir / Pasar'), findsOneWidget);
      expect(find.text('Belum ada struk dipilih'), findsOneWidget);
      expect(find.text('Pilih foto struk yang jelas untuk mulai memindai.'), findsOneWidget);
      expect(find.text('0 Item Terdeteksi'), findsOneWidget);
      expect(find.text('Belum ada struk yang diunggah.'), findsOneWidget);
      expect(find.text('mm/dd/yyyy'), findsOneWidget);
      expect(find.text('0 bahan'), findsOneWidget);
    });

    testWidgets('tombol simpan belum muncul sebelum ada baris', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      expect(find.text('+ Tambah ke Pantry'), findsNothing);
    });
  });

  group('baris bahan', () {
    testWidgets('Tambah Baris menambah baris dan memperbarui hitungan', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tapText(tester, '+ Tambah Baris');
      expect(find.text('1 bahan'), findsOneWidget);
      expect(find.text('1 Item Terdeteksi'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // nama + jumlah

      await tapText(tester, '+ Tambah Baris');
      expect(find.text('2 bahan'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('tombol simpan muncul setelah ada baris', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapText(tester, '+ Tambah Baris');

      expect(find.text('+ Tambah ke Pantry'), findsOneWidget);
    });

    testWidgets('Hapus baris mengembalikan ke keadaan kosong', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapText(tester, '+ Tambah Baris');

      await tapText(tester, 'Hapus baris');

      expect(find.text('0 bahan'), findsOneWidget);
      expect(find.text('+ Tambah ke Pantry'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('simpan', () {
    testWidgets('baris kosong menampilkan error dan layar tidak tertutup', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapText(tester, '+ Tambah Baris');

      await tapText(tester, '+ Tambah ke Pantry');

      expect(find.text('Isi nama (min. 2 huruf) dan jumlah lebih dari 0.'), findsOneWidget);
      expect(find.text('Pindai Struk Belanja Kasir / Pasar'), findsOneWidget); // masih di layar
    });

    testWidgets('jumlah nol ditolak', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapText(tester, '+ Tambah Baris');
      await tester.enterText(find.byType(TextField).at(0), 'Bayam');
      await tester.enterText(find.byType(TextField).at(1), '0');

      await tapText(tester, '+ Tambah ke Pantry');

      expect(find.text('Isi nama (min. 2 huruf) dan jumlah lebih dari 0.'), findsOneWidget);
    });

    testWidgets('satu baris valid + satu salah: tidak ada yang tersimpan', (tester) async {
      usePhoneScreen(tester);
      Object? result = 'belum';
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tapText(tester, '+ Tambah Baris');
      await tapText(tester, '+ Tambah Baris');
      await tester.enterText(find.byType(TextField).at(0), 'Bayam');
      await tester.enterText(find.byType(TextField).at(1), '2');
      // baris kedua dibiarkan kosong
      await tapText(tester, '+ Tambah ke Pantry');

      expect(find.text('Isi nama (min. 2 huruf) dan jumlah lebih dari 0.'), findsOneWidget);
      expect(result, 'belum');
    });

    testWidgets('baris valid dikembalikan dalam format API pantry', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tapText(tester, '+ Tambah Baris');
      await tester.enterText(find.byType(TextField).at(0), 'Bayam');
      await tester.enterText(find.byType(TextField).at(1), '2,5');
      await tapText(tester, '+ Tambah ke Pantry');

      expect(find.text('open'), findsOneWidget);
      expect(result, {
        'source': 'ocr',
        'items': [
          {'name': 'Bayam', 'quantity': 2.5, 'unit': 'g', 'starting_on': null},
        ],
      });
    });
  });

  group('tanggal belanja', () {
    testWidgets('memilih tanggal menampilkannya dengan format mm/dd/yyyy', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tapText(tester, 'mm/dd/yyyy');
      await tester.tap(find.text('OK')); // default pemilih = hari ini
      await tester.pumpAndSettle();

      final now = DateTime.now();
      expect(find.text('${two(now.month)}/${two(now.day)}/${now.year}'), findsOneWidget);
      expect(find.text('mm/dd/yyyy'), findsNothing);
    });

    testWidgets('tanggal yang dipilih ikut terkirim sebagai starting_on (yyyy-MM-dd)', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tapText(tester, 'mm/dd/yyyy');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tapText(tester, '+ Tambah Baris');
      await tester.enterText(find.byType(TextField).at(0), 'Bayam');
      await tester.enterText(find.byType(TextField).at(1), '1');
      await tapText(tester, '+ Tambah ke Pantry');

      final now = DateTime.now();
      final items = (result as Map)['items'] as List;
      expect((items.first as Map)['starting_on'], '${now.year}-${two(now.month)}-${two(now.day)}');
    });
  });

  group('panduan dan unggah', () {
    testWidgets('link panduan membuka dan menutup dialog', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tapText(tester, 'Panduan foto struk yang bisa dipindai');
      expect(find.text('Panduan foto struk'), findsOneWidget); // judul dialog
      expect(find.textContaining('maksimal 10 MB'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Panduan foto struk'), findsNothing);
    });

    // Tes ini sengaja mengunci perilaku sementara. Saat OCR sudah tersambung,
    // ubah tes ini lebih dulu (red) lalu implementasikan (green).
    testWidgets('unggah struk belum tersambung ke OCR (placeholder)', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tapText(tester, 'Unggah Struk Belanja');

      expect(find.text('Unggah struk belum tersambung ke OCR'), findsOneWidget);
    });
  });

  testWidgets('tombol Kembali menutup layar tanpa hasil', (tester) async {
    usePhoneScreen(tester);
    Object? result = 'belum';
    await tester.pumpWidget(hostedPage((r) => result = r));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('‹ Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(result, isNull);
  });
}