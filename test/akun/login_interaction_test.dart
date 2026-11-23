import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/main.dart';

import 'login_validation_test.dart' show fillLogin;

void main() {
  testWidgets('tema gelap mengikuti navigasi login ke daftar dan kembali', (
    tester,
  ) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.ensureVisible(find.text('Akun'));
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Gunakan mode gelap'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gunakan mode gelap'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('DaftarKuy'));
    await tester.tap(find.text('DaftarKuy'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFF0F1713),
    );
    await tester.ensureVisible(find.text('MasukKuy'));
    await tester.tap(find.text('MasukKuy'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFF0F1713),
    );
  });

  testWidgets(
    'kata sandi bisa ditampilkan dan disembunyikan tanpa mengubah isi',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AkunPage()));
      await fillLogin(tester, 'password', 'Rahasia42!');
      final input = find.descendant(
        of: find.byKey(const ValueKey('login-password')),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(input).obscureText, isTrue);
      await tester.tap(find.byTooltip('Tampilkan kata sandi'));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(input).obscureText, isFalse);
      expect(tester.widget<EditableText>(input).controller.text, 'Rahasia42!');
      expect(tester.widget<EditableText>(input).enableSuggestions, isFalse);
      await tester.tap(find.byTooltip('Sembunyikan kata sandi'));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(input).obscureText, isTrue);
    },
  );

  testWidgets('ingat saya dapat dicentang dan dibatalkan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.text('Ingat saya'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('ganti tema mempertahankan isian dan pilihan ingat saya', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));
    await fillLogin(tester, 'identifier', 'attar_rais');
    await tester.tap(find.text('Ingat saya'));
    await tester.ensureVisible(find.byTooltip('Gunakan mode gelap'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gunakan mode gelap'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFF0F1713),
    );
    expect(find.text('attar_rais'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byTooltip('Gunakan mode terang'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFE9FFF4),
    );
  });

  testWidgets('login dan daftar bolak-balik tanpa menumpuk halaman login', (
    tester,
  ) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.ensureVisible(find.text('Akun'));
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    await fillLogin(tester, 'identifier', 'attar_rais');
    for (var index = 0; index < 2; index++) {
      await tester.ensureVisible(find.text('DaftarKuy'));
      await tester.tap(find.text('DaftarKuy'));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Akun'), findsOneWidget);
      await tester.ensureVisible(find.text('MasukKuy'));
      await tester.tap(find.text('MasukKuy'));
      await tester.pumpAndSettle();
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('attar_rais'), findsOneWidget);
    }
    await tester.ensureVisible(find.text('Kembali ke beranda'));
    await tester.tap(find.text('Kembali ke beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsNothing);
  });
}
