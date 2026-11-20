import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/akun/screens/signup_page.dart';
import 'package:takarkuy_apk/main.dart';

import 'signup_validation_test.dart' show fillField, fillValidForm, submitForm;

void main() {
  testWidgets('tombol mata hanya mengubah visibilitas kolom terkait', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillField(tester, 'password', 'DapurKuy42!');
    await fillField(tester, 'confirmation', 'DapurKuy42!');

    Finder input(String id) => find.descendant(
      of: find.byKey(ValueKey('signup-$id')),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(input('password')).obscureText, isTrue);
    await tester.ensureVisible(find.byTooltip('Tampilkan Kata Sandi'));
    await tester.tap(find.byTooltip('Tampilkan Kata Sandi'));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(input('password')).obscureText, isFalse);
    expect(
      tester.widget<EditableText>(input('confirmation')).obscureText,
      isTrue,
    );
    expect(
      tester.widget<EditableText>(input('password')).controller.text,
      'DapurKuy42!',
    );

    await tester.tap(find.byTooltip('Sembunyikan Kata Sandi'));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(input('password')).obscureText, isTrue);
  });

  testWidgets('tema dapat diganti tanpa menghilangkan isian', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillField(tester, 'name', 'Attar Rais');
    await tester.ensureVisible(find.byTooltip('Gunakan mode gelap'));
    await tester.tap(find.byTooltip('Gunakan mode gelap'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFF0F1713),
    );
    expect(find.text('Attar Rais'), findsOneWidget);
    await tester.tap(find.byTooltip('Gunakan mode terang'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFF2F8F4),
    );
    expect(find.text('Attar Rais'), findsOneWidget);
  });

  testWidgets(
    'syarat membuka dialog dan tidak otomatis mencentang persetujuan',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      await tester.ensureVisible(find.byKey(const ValueKey('signup-terms')));
      await tester.tap(find.byKey(const ValueKey('signup-terms')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Syarat & Ketentuan'), findsOneWidget);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    },
  );

  testWidgets(
    'submit valid memberi informasi tanpa mengklaim akun telah dibuat',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      await fillValidForm(tester);
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await submitForm(tester);
      expect(find.text('Pendaftaran belum tersedia'), findsOneWidget);
      expect(find.text('Akun berhasil dibuat'), findsNothing);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();
      expect(find.text('Attar Rais'), findsOneWidget);
    },
  );

  testWidgets('aksi selesai di keyboard memvalidasi formulir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillField(tester, 'confirmation', 'Berbeda42!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Isi nama lengkapmu.'), findsOneWidget);
  });

  testWidgets('tautan MasukKuy dari layar mandiri membuka login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Buka Register'),
            ),
          ),
        ),
        routes: {
          '/signup': (_) => const SignupPage(),
          '/login': (_) => const AkunPage(),
        },
      ),
    );
    await tester.tap(find.text('Buka Register'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('MasukKuy'));
    await tester.tap(find.text('MasukKuy'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Login'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Buka Register'), findsOneWidget);
  });

  testWidgets('kartu Akun membuka login dan MasukKuy kembali tanpa duplikasi', (
    tester,
  ) async {
    await tester.pumpWidget(const TakarKuyApp());
    await tester.ensureVisible(find.text('Akun'));
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Login'), findsOneWidget);
    await tester.tap(find.text('Buka halaman daftar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('MasukKuy'));
    await tester.tap(find.text('MasukKuy'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Login'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Akun'), findsOneWidget);
  });
}
