import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';

Future<void> fillLogin(WidgetTester tester, String id, String value) async {
  final field = find.byKey(ValueKey('login-$id'));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> submitLogin(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'MasukKuy');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login kosong menampilkan kesalahan pada kedua kolom', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));
    await submitLogin(tester);
    expect(find.text('Isi email atau username.'), findsOneWidget);
    expect(find.text('Isi kata sandi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'identifier berisi spasi saja ditolak tanpa menghapus kata sandi',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AkunPage()));
      await fillLogin(tester, 'identifier', '   ');
      await fillLogin(tester, 'password', 'KataSandiLama');
      await submitLogin(tester);
      expect(find.text('Isi email atau username.'), findsOneWidget);
      expect(find.text('Isi kata sandi.'), findsNothing);
      final password = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('login-password')),
          matching: find.byType(EditableText),
        ),
      );
      expect(password.controller.text, 'KataSandiLama');
    },
  );

  for (final identifier in ['attar_rais', 'attar@example.com']) {
    testWidgets(
      'login menerima $identifier tanpa menerapkan aturan password daftar',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: AkunPage()));
        await fillLogin(tester, 'identifier', identifier);
        await fillLogin(tester, 'password', 'lama');
        await submitLogin(tester);
        expect(find.text('Login belum tersedia'), findsOneWidget);
        expect(find.text('Berhasil masuk'), findsNothing);
        await tester.tap(find.text('Mengerti'));
        await tester.pumpAndSettle();
        expect(find.text(identifier), findsOneWidget);
      },
    );
  }

  testWidgets('tombol selesai pada keyboard memvalidasi login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));
    await fillLogin(tester, 'password', 'lama');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Isi email atau username.'), findsOneWidget);
  });
}
