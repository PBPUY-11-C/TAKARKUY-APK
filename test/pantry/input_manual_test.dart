import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan nama paket dengan `name:` di pubspec.yaml proyek Anda.
import 'package:takarkuy_apk/pantry/screens/input_manual.dart';

/// Layar setinggi ponsel (390 x 844) supaya form dan tombol muat di layar tes.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Widget directPage() => const MaterialApp(home: InputManualPage());

/// Halaman dibuka lewat tombol 'open' agar hasil Navigator.pop bisa ditangkap.
Widget hostedPage(void Function(Object? result) onResult) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async => onResult(await Navigator.push<Object?>(
                context,
                MaterialPageRoute(builder: (_) => const InputManualPage()),
              )),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> tapSubmit(WidgetTester tester) async {
  final button = find.text('+ Tambah ke Pantry');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  final nameField = find.byType(TextField).at(0);
  final quantityField = find.byType(TextField).at(1);

  group('tampilan awal', () {
    testWidgets('menampilkan semua isian dan nilai awal sesuai desain', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      expect(find.text('Input manual'), findsOneWidget);
      expect(find.text('* Wajib diisi · Tanpa struk'), findsOneWidget);
      for (final label in ['Nama Bahan Makanan *', 'Kategori *', 'Jumlah *', 'Satuan *']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Sayur & Buah'), findsOneWidget); // kategori awal
      expect(find.text('gram (g)'), findsOneWidget); // satuan awal
      expect(find.text('+ Tambah ke Pantry'), findsOneWidget);
    });

    testWidgets('belum ada pesan error saat pertama dibuka', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      expect(find.text('Nama bahan makanan wajib diisi.'), findsNothing);
      expect(find.text('Jumlah wajib diisi.'), findsNothing);
    });
  });

  group('validasi', () {
    testWidgets('form kosong: error muncul di nama dan jumlah', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapSubmit(tester);

      expect(find.text('Nama bahan makanan wajib diisi.'), findsOneWidget);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget);
    });

    testWidgets('error nama berada tepat di bawah kolom nama', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapSubmit(tester);

      final fieldBottom = tester.getBottomLeft(nameField).dy;
      final errorTop = tester.getTopLeft(find.text('Nama bahan makanan wajib diisi.')).dy;
      final nextLabelTop = tester.getTopLeft(find.text('Kategori *')).dy;
      expect(errorTop, greaterThan(fieldBottom));
      expect(errorTop, lessThan(nextLabelTop));
    });

    testWidgets('hanya kolom yang salah yang menampilkan error', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tester.enterText(nameField, 'Tempe'); // nama benar, jumlah kosong
      await tapSubmit(tester);

      expect(find.text('Nama bahan makanan wajib diisi.'), findsNothing);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget);
    });

    testWidgets('nama satu huruf dianggap terlalu pendek', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tester.enterText(nameField, 'a');
      await tester.enterText(quantityField, '2');
      await tapSubmit(tester);

      expect(find.text('Nama bahan terlalu pendek.'), findsOneWidget);
    });

    testWidgets('jumlah bukan angka atau nol ditolak', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tester.enterText(nameField, 'Tempe');

      for (final bad in ['abc', '0', '-3']) {
        await tester.enterText(quantityField, bad);
        await tapSubmit(tester);
        expect(find.text('Jumlah harus berupa angka lebih dari 0.'), findsOneWidget,
            reason: 'jumlah "$bad" seharusnya ditolak');
      }
    });

    testWidgets('error hilang begitu kolomnya diketik ulang', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());
      await tapSubmit(tester);
      expect(find.text('Nama bahan makanan wajib diisi.'), findsOneWidget);

      await tester.enterText(nameField, 'Tempe');
      await tester.pump();

      expect(find.text('Nama bahan makanan wajib diisi.'), findsNothing);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget); // kolom lain tidak ikut hilang
    });
  });

  group('hasil submit', () {
    testWidgets('data valid menutup layar dan mengembalikan Map', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, '  Tempe   goreng ');
      await tester.enterText(quantityField, '2');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget); // kembali ke halaman asal
      expect(result, {
        'name': 'Tempe goreng', // spasi dirapikan
        'category': 'sayur_buah',
        'quantity': 2.0,
        'unit': 'g',
      });
    });

    testWidgets('koma desimal diterima (1,5 -> 1.5)', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, 'Santan');
      await tester.enterText(quantityField, '1,5');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect((result as Map)['quantity'], 1.5);
    });

    testWidgets('kategori dan satuan yang dipilih ikut terkirim (kode backend)', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sayur & Buah')); // buka dropdown kategori
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('gram (g)')); // buka dropdown satuan
      await tester.pumpAndSettle();
      await tester.tap(find.text('kilogram (kg)'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, 'Garam');
      await tester.enterText(quantityField, '1');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect((result as Map)['category'], 'lainnya');
      expect((result as Map)['unit'], 'kg');
    });

    testWidgets('data tidak valid tidak menutup layar', (tester) async {
      usePhoneScreen(tester);
      Object? result = 'belum';
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Input manual'), findsOneWidget); // masih di form
      expect(result, 'belum'); // pop belum terjadi
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