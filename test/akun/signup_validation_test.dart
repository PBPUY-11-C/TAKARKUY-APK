import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/akun/screens/signup_page.dart';

Future<void> fillField(WidgetTester tester, String id, String value) async {
  final field = find.byKey(ValueKey('signup-$id'));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> fillValidForm(WidgetTester tester) async {
  await fillField(tester, 'name', 'Attar Rais');
  await fillField(tester, 'username', 'attar_rais');
  await fillField(tester, 'email', 'attar@example.com');
  await fillField(tester, 'password', 'DapurKuy42!');
  await fillField(tester, 'confirmation', 'DapurKuy42!');
}

Future<void> submitForm(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'DaftarKuy');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('form kosong menampilkan kesalahan sesuai kolom', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await submitForm(tester);

    for (final message in [
      'Isi nama lengkapmu.',
      'Isi username.',
      'Masukkan email yang valid.',
      'Buat kata sandi.',
      'Ulangi kata sandi.',
      'Setujui syarat terlebih dahulu.',
    ]) {
      expect(find.text(message), findsOneWidget);
    }
  });

  testWidgets('username, email, dan konfirmasi yang salah ditolak', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillValidForm(tester);
    await fillField(tester, 'username', 'att@r');
    await fillField(tester, 'email', 'attar @example.com');
    await fillField(tester, 'confirmation', 'Berbeda42!');
    await submitForm(tester);

    expect(
      find.text('Gunakan 3–30 huruf, angka, titik, _ atau -.'),
      findsOneWidget,
    );
    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi belum cocok.'), findsOneWidget);
    expect(find.text('Pendaftaran belum tersedia'), findsNothing);
  });

  for (final entry in {
    'Kuy1!': 'Gunakan minimal 8 karakter.',
    'dapurku42!': 'Tambahkan huruf kapital.',
    'DapurKuy!!': 'Tambahkan angka.',
    'DapurKuy42': 'Tambahkan simbol.',
  }.entries) {
    testWidgets('kata sandi ${entry.value} ditolak', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      await fillValidForm(tester);
      await fillField(tester, 'password', entry.key);
      await fillField(tester, 'confirmation', entry.key);
      await submitForm(tester);
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets(
    'indikator persyaratan diperbarui dan kembali saat isian dihapus',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      await fillField(tester, 'password', 'DapurKuy42!');
      await fillField(tester, 'confirmation', 'DapurKuy42!');
      await tester.ensureVisible(find.text('Min 8'));
      await tester.pumpAndSettle();
      for (final label in ['Min 8', 'Kapital', 'Angka', 'Simbol', 'Cocok']) {
        expect(find.bySemanticsLabel('$label: terpenuhi'), findsOneWidget);
      }

      await fillField(tester, 'confirmation', '');
      await tester.ensureVisible(find.text('Cocok'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Cocok: belum terpenuhi'), findsOneWidget);
    },
  );

  testWidgets('persetujuan wajib dan kesalahan hilang setelah dicentang', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillValidForm(tester);
    await submitForm(tester);
    expect(find.text('Setujui syarat terlebih dahulu.'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Setujui syarat terlebih dahulu.'), findsNothing);
  });
}
