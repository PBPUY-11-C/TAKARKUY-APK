import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/pantry/screens/edit_item.dart';

/// Layar setinggi ponsel (390 x 844) supaya form dan tombol muat di layar tes.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

EditItemPage buildEditPage({
  String name = 'Tempe',
  double quantity = 2,
  String unit = 'pack / bungkus',
  String category = 'Tahu, Tempe & Kacang',
  String location = 'Kulkas',
  DateTime? expiresOn,
}) =>
    EditItemPage(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      location: location,
      expiresOn: expiresOn,
    );

Widget directPage({
  String name = 'Tempe',
  double quantity = 2,
  String unit = 'pack / bungkus',
  String category = 'Tahu, Tempe & Kacang',
  String location = 'Kulkas',
  DateTime? expiresOn,
}) =>
    MaterialApp(
      home: buildEditPage(
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        location: location,
        expiresOn: expiresOn,
      ),
    );

/// Halaman dibuka lewat tombol 'open' agar hasil Navigator.pop bisa ditangkap.
Widget hostedPage(
  void Function(Object? result) onResult, {
  String name = 'Tempe',
  double quantity = 2,
  String unit = 'pack / bungkus',
  String category = 'Tahu, Tempe & Kacang',
  String location = 'Kulkas',
  DateTime? expiresOn,
}) =>
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async => onResult(await Navigator.push<Object?>(
                context,
                MaterialPageRoute(
                  builder: (_) => buildEditPage(
                    name: name,
                    quantity: quantity,
                    unit: unit,
                    category: category,
                    location: location,
                    expiresOn: expiresOn,
                  ),
                ),
              )),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> tapSave(WidgetTester tester) async {
  final button = find.text('Simpan');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  final nameField = find.byType(TextField).at(0);
  final quantityField = find.byType(TextField).at(1);

  group('tampilan awal', () {
    testWidgets('menampilkan nilai awal bahan dan format jumlah bulat', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      expect(find.text('Edit bahan'), findsOneWidget);
      for (final label in ['Nama bahan *', 'Jumlah *', 'Satuan *', 'Kategori', 'Lokasi simpan']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.widget<TextField>(nameField).controller?.text, 'Tempe');
      expect(tester.widget<TextField>(quantityField).controller?.text, '2');
      expect(find.text('pack / bungkus'), findsOneWidget);
      expect(find.text('Tahu, Tempe & Kacang'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);
      expect(find.text('Tanggal kedaluwarsa'), findsNothing); // tertutup jika expiresOn null
    });

    testWidgets('menampilkan jumlah desimal apa adanya', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage(quantity: 1.5));

      expect(tester.widget<TextField>(quantityField).controller?.text, '1.5');
    });

    testWidgets('fallback ke nilai default jika satuan/kategori/lokasi tidak dikenal', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage(
        unit: 'tidak_ada',
        category: 'tidak_ada',
        location: 'tidak_ada',
      ));

      expect(find.text('gram (g)'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);
    });

    testWidgets('detail tanggal otomatis terbuka jika expiresOn tersedia', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage(expiresOn: DateTime(2026, 5, 14)));

      expect(find.text('Tanggal kedaluwarsa'), findsOneWidget);
      expect(find.text('14 Mei 2026'), findsOneWidget);
      expect(find.text('Hapus tanggal'), findsOneWidget);
    });
  });

  group('validasi', () {
    testWidgets('nama dan jumlah kosong menampilkan pesan error', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tester.enterText(nameField, '');
      await tester.enterText(quantityField, '');
      await tapSave(tester);

      expect(find.text('Nama bahan wajib diisi.'), findsOneWidget);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget);
    });

    testWidgets('nama satu huruf dianggap terlalu pendek', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tester.enterText(nameField, 'a');
      await tapSave(tester);

      expect(find.text('Nama bahan terlalu pendek.'), findsOneWidget);
    });

    testWidgets('jumlah bukan angka, nol, atau negatif ditolak', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      for (final bad in ['abc', '0', '-2']) {
        await tester.enterText(quantityField, bad);
        await tapSave(tester);
        expect(find.text('Jumlah harus berupa angka lebih dari 0.'), findsOneWidget,
            reason: 'jumlah "$bad" seharusnya ditolak');
      }
    });

    testWidgets('error hilang saat kolom diketik ulang tanpa menghapus error kolom lain', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(directPage());

      await tester.enterText(nameField, '');
      await tester.enterText(quantityField, '');
      await tapSave(tester);

      expect(find.text('Nama bahan wajib diisi.'), findsOneWidget);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget);

      await tester.enterText(nameField, 'Tahu');
      await tester.pump();

      expect(find.text('Nama bahan wajib diisi.'), findsNothing);
      expect(find.text('Jumlah wajib diisi.'), findsOneWidget);
    });
  });

  group('hasil simpan', () {
    testWidgets('data valid menutup layar dan mengembalikan Map action save', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      final expiry = DateTime(2026, 8, 20);
      await tester.pumpWidget(hostedPage((r) => result = r, expiresOn: expiry));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, '  Tempe   mendoan  ');
      await tester.enterText(quantityField, '2,5');
      await tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(result, {
        'action': 'save',
        'name': 'Tempe mendoan',
        'quantity': 2.5,
        'unit': 'pack / bungkus',
        'category': 'Tahu, Tempe & Kacang',
        'location': 'Kulkas',
        'expiresOn': expiry,
      });
    });

    testWidgets('perubahan dropdown satuan, kategori, dan lokasi ikut terkirim', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('pack / bungkus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('kilogram (kg)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tahu, Tempe & Kacang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bumbu & Minyak'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kulkas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suhu Ruang'));
      await tester.pumpAndSettle();

      await tapSave(tester);
      await tester.pumpAndSettle();

      final map = result as Map;
      expect(map['unit'], 'kilogram (kg)');
      expect(map['category'], 'Bumbu & Minyak');
      expect(map['location'], 'Suhu Ruang');
    });

    testWidgets('hapus tanggal mengosongkan expiresOn saat disimpan', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r, expiresOn: DateTime(2026, 12, 1)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final removeDate = find.text('Hapus tanggal');
      await tester.ensureVisible(removeDate);
      await tester.tap(removeDate);
      await tester.pump();

      expect(find.text('Pilih tanggal'), findsOneWidget);
      expect(find.text('Hapus tanggal'), findsNothing);

      await tapSave(tester);
      await tester.pumpAndSettle();

      expect((result as Map)['expiresOn'], isNull);
    });

    testWidgets('data tidak valid tidak menutup layar', (tester) async {
      usePhoneScreen(tester);
      Object? result = 'belum';
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, '');
      await tapSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Edit bahan'), findsOneWidget);
      expect(result, 'belum');
    });
  });

  group('hapus bahan', () {
    testWidgets('batal pada dialog konfirmasi tidak menghapus dan tetap di halaman', (tester) async {
      usePhoneScreen(tester);
      Object? result = 'belum';
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final deleteBtn = find.text('Hapus');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Hapus bahan?'), findsOneWidget);
      expect(find.text('"Tempe" akan dihapus dari stok.'), findsOneWidget);

      final cancelDialogBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Batal'),
      );
      await tester.tap(cancelDialogBtn);
      await tester.pumpAndSettle();

      expect(find.text('Edit bahan'), findsOneWidget);
      expect(result, 'belum');
    });

    testWidgets('konfirmasi hapus menutup layar dengan action delete', (tester) async {
      usePhoneScreen(tester);
      Object? result;
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final deleteBtn = find.text('Hapus');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      final confirmDialogBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Hapus'),
      );
      await tester.tap(confirmDialogBtn);
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(result, {'action': 'delete'});
    });
  });

  group('navigasi batal', () {
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

    testWidgets('tombol Batal di bar bawah menutup layar tanpa hasil', (tester) async {
      usePhoneScreen(tester);
      Object? result = 'belum';
      await tester.pumpWidget(hostedPage((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(result, isNull);
    });
  });
}