import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/pantry/widgets/pantry_card.dart';

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Kartu berdiri sendiri, dengan data yang diatur langsung dari tes.
Widget cardHost({
  bool expanded = false,
  VoidCallback? onToggle,
  VoidCallback? onEdit,
  String expiry = '1 hari lagi',
  String expiryDate = '24 Nov 2026',
}) =>
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: PantryCard(
            name: 'Daging Ayam',
            quantity: 'Jumlah: 620 gram (g)',
            expiry: expiry,
            category: 'Daging & Seafood',
            location: 'Kulkas',
            expiryDate: expiryDate,
            expanded: expanded,
            onToggle: onToggle ?? () {},
            onEdit: onEdit ?? () {},
          ),
        ),
      ),
    );

void main() {
  final today = DateTime(2026, 11, 23);

  group('PantryCard (berdiri sendiri)', () {
    testWidgets('menampilkan ringkasan: nama, jumlah, sisa hari', (tester) async {
      await tester.pumpWidget(cardHost());

      expect(find.text('Daging Ayam'), findsOneWidget);
      expect(find.text('Jumlah: 620 gram (g)'), findsOneWidget);
      expect(find.text('1 hari lagi'), findsOneWidget);
    });

    testWidgets('tertutup: detail tidak tampil', (tester) async {
      await tester.pumpWidget(cardHost(expanded: false));

      expect(find.text('Daging & Seafood'), findsNothing);
      expect(find.text('Kulkas'), findsNothing);
      expect(find.text('24 Nov 2026'), findsNothing);
      expect(find.text('Ubah'), findsNothing);
    });

    testWidgets('terbuka: detail tampil lengkap', (tester) async {
      await tester.pumpWidget(cardHost(expanded: true));
      await tester.pumpAndSettle();

      expect(find.text('Daging & Seafood'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);
      expect(find.text('24 Nov 2026'), findsOneWidget);
      expect(find.text('Ubah'), findsOneWidget);
    });

    testWidgets('mengetuk ringkasan memanggil onToggle', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(cardHost(onToggle: () => toggles++));

      await tester.tap(find.text('Daging Ayam'));
      await tester.pump();

      expect(toggles, 1);
    });

    testWidgets('tombol Ubah memanggil onEdit, bukan onToggle', (tester) async {
      var toggles = 0, edits = 0;
      await tester.pumpWidget(
        cardHost(expanded: true, onToggle: () => toggles++, onEdit: () => edits++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ubah'));
      await tester.pump();

      expect(edits, 1);
      expect(toggles, 0);
    });

    testWidgets('buka-tutup mengikuti perubahan expanded dari induk', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              var open = false;
              return StatefulBuilder(
                builder: (context, setInner) => PantryCard(
                  name: 'Daging Ayam',
                  quantity: 'Jumlah: 620 gram (g)',
                  expiry: '1 hari lagi',
                  category: 'Daging & Seafood',
                  location: 'Kulkas',
                  expiryDate: '24 Nov 2026',
                  expanded: open,
                  onToggle: () => setInner(() => open = !open),
                  onEdit: () {},
                ),
              );
            },
          ),
        ),
      ));

      expect(find.text('Ubah'), findsNothing);
      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      expect(find.text('Ubah'), findsOneWidget);
      await tester.tap(find.text('Daging Ayam'));
      await tester.pumpAndSettle();
      expect(find.text('Ubah'), findsNothing);
    });

    testWidgets('bahan tanpa tanggal: kedua teks tanggal sama-sama jelas', (tester) async {
      await tester.pumpWidget(cardHost(
        expanded: true,
        expiry: 'Tanggal belum diketahui',
        expiryDate: 'Tanggal belum diketahui',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tanggal belum diketahui'), findsNWidgets(2)); // ringkasan + detail
    });
  });

  group('kartu di PantryPage', () {
    PantryPage page() => PantryPage(
          today: today,
          items: [
            PantryItem(id: '1', name: 'Susu', quantity: 1.5, unit: 'liter', category: 'Lainnya', location: 'Kulkas', expiresOn: DateTime(2026, 11, 24)),
            PantryItem(id: '2', name: 'Roti', quantity: 2, unit: 'buah', category: 'Beras & Karbohidrat', location: 'Suhu Ruang', expiresOn: DateTime(2026, 11, 21)),
            const PantryItem(id: '3', name: 'Garam', quantity: 20, category: 'Bumbu & Minyak', location: 'Suhu Ruang'),
          ],
        );

    Future<void> open(WidgetTester tester, [PantryPage? p]) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(MaterialApp(home: p ?? page()));
    }

    testWidgets('satu kartu untuk setiap bahan', (tester) async {
      await open(tester);

      expect(find.byType(PantryCard), findsNWidgets(3));
      expect(find.text('Susu'), findsOneWidget);
      expect(find.text('Roti'), findsOneWidget);
      expect(find.text('Garam'), findsOneWidget);
    });

    testWidgets('isi ringkasan berasal dari model', (tester) async {
      await open(tester);

      expect(find.text('Jumlah: 1.5 liter'), findsOneWidget);
      expect(find.text('1 hari lagi'), findsOneWidget);
      expect(find.text('Kedaluwarsa 2 hari lalu'), findsOneWidget);
      expect(find.text('Tanggal belum diketahui'), findsOneWidget);
    });

    testWidgets('mengetuk kartu membuka detail dengan tanggal terformat', (tester) async {
      await open(tester);

      await tester.tap(find.text('Susu'));
      await tester.pumpAndSettle();

      expect(find.text('Lainnya'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);
      expect(find.text('24 Nov 2026'), findsOneWidget);
      expect(find.text('Ubah'), findsOneWidget);
    });

    testWidgets('hanya satu kartu terbuka pada satu waktu', (tester) async {
      await open(tester);

      await tester.tap(find.text('Susu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Roti'));
      await tester.pumpAndSettle();

      expect(find.text('Ubah'), findsOneWidget);
      expect(find.text('Beras & Karbohidrat'), findsOneWidget); // detail Roti
      expect(find.text('24 Nov 2026'), findsNothing); // detail Susu sudah tertutup
    });

    testWidgets('mengetuk kartu yang sama menutupnya', (tester) async {
      await open(tester);

      await tester.tap(find.text('Susu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Susu'));
      await tester.pumpAndSettle();

      expect(find.text('Ubah'), findsNothing);
    });

    testWidgets('tombol Ubah membuka form Edit bahan', (tester) async {
      await open(tester);

      await tester.tap(find.text('Susu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();

      expect(find.text('Edit bahan'), findsOneWidget);
    });

    testWidgets('tanpa items: memakai data buatan', (tester) async {
      await open(tester, const PantryPage());

      expect(find.byType(PantryCard), findsWidgets);
      expect(find.text('Daging Ayam'), findsOneWidget);
      expect(find.text('Jumlah: 620 gram (g)'), findsOneWidget);
    });
  });

  group('PantryItem (label untuk kartu)', () {
    PantryItem item({double q = 620, String unit = 'gram (g)', DateTime? exp}) => PantryItem(
          id: 'x',
          name: 'Tes',
          quantity: q,
          unit: unit,
          category: 'Lainnya',
          location: 'Kulkas',
          expiresOn: exp,
        );

    test('quantityLabel: bulat tanpa .0, desimal tetap tampil', () {
      expect(item(q: 620).quantityLabel, 'Jumlah: 620 gram (g)');
      expect(item(q: 1.5, unit: 'liter').quantityLabel, 'Jumlah: 1.5 liter');
    });

    test('expiryLabel: lewat, hari ini, mendatang, tanpa tanggal', () {
      expect(item(exp: DateTime(2026, 11, 21)).expiryLabel(today), 'Kedaluwarsa 2 hari lalu');
      expect(item(exp: DateTime(2026, 11, 23)).expiryLabel(today), 'Hari ini');
      expect(item(exp: DateTime(2026, 11, 24)).expiryLabel(today), '1 hari lagi');
      expect(item().expiryLabel(today), 'Tanggal belum diketahui');
    });

    test('daysLeft mengabaikan jam dan melewati batas bulan', () {
      final lateNight = DateTime(2026, 11, 30, 23, 59);
      expect(item(exp: DateTime(2026, 12, 1)).daysLeft(lateNight), 1);
      expect(item().daysLeft(today), isNull);
    });

    test('expiryDateLabel memakai singkatan bulan Indonesia', () {
      expect(item(exp: DateTime(2026, 5, 3)).expiryDateLabel, '3 Mei 2026');
      expect(item(exp: DateTime(2026, 8, 17)).expiryDateLabel, '17 Agu 2026');
      expect(item(exp: DateTime(2026, 12, 31)).expiryDateLabel, '31 Des 2026');
      expect(item().expiryDateLabel, isNull);
    });
  });

  group('sampleItems (data buatan)', () {
    test('4 bahan dengan id unik', () {
      final items = sampleItems(today);
      expect(items, hasLength(4));
      expect(items.map((e) => e.id).toSet(), hasLength(4));
    });

    test('tanggal kedaluwarsa dihitung dari hari ini', () {
      final items = sampleItems(today);
      expect(items.first.name, 'Daging Ayam');
      expect(items.first.expiryLabel(today), '1 hari lagi');
      expect(items.firstWhere((e) => e.name == 'Jagung Manis').expiryDateLabel, '22 Jan 2027');
    });

    test('Bihun dan Garam belum punya tanggal', () {
      final items = sampleItems(today);
      for (final name in ['Bihun', 'Garam']) {
        expect(items.firstWhere((e) => e.name == name).expiresOn, isNull);
      }
    });
  });
}