import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/features/akun/screens/signup_page.dart';

import 'login_validation_test.dart' show fillLogin, submitLogin;
import 'signup_validation_test.dart' show fillField, fillValidForm, submitForm;

Finder summary(String page) => find.byKey(ValueKey('$page-error-summary'));

TextField input(WidgetTester tester, String key) => tester.widget<TextField>(
  find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextField),
  ),
);

Future<void> acceptTerms(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(Checkbox));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox));
  await tester.pumpAndSettle();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'login memberi ringkasan dan sorotan error ${brightness.name}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const AkunPage(),
          ),
        );
        expect(summary('login'), findsNothing);
        final originalFill = input(
          tester,
          'login-identifier',
        ).decoration!.fillColor;
        await submitLogin(tester);

        expect(find.text('Periksa isian login'), findsOneWidget);
        expect(summary('login').hitTestable(), findsOneWidget);
        expect(find.text('Isi email atau username.'), findsOneWidget);
        expect(find.text('Isi kata sandi.'), findsOneWidget);
        expect(
          input(tester, 'login-identifier').decoration!.fillColor,
          isNot(originalFill),
        );
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          tester.widget<Semantics>(summary('login')).properties.liveRegion,
          isTrue,
        );
      },
    );

    testWidgets(
      'register memberi ringkasan dan sorotan error ${brightness.name}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const SignupPage(),
          ),
        );
        expect(summary('signup'), findsNothing);
        final originalFill = input(tester, 'signup-name').decoration!.fillColor;
        await submitForm(tester);

        expect(find.text('Periksa formulir'), findsOneWidget);
        expect(summary('signup').hitTestable(), findsOneWidget);
        expect(
          input(tester, 'signup-name').decoration!.fillColor,
          isNot(originalFill),
        );
        expect(find.text('Isi nama lengkapmu.'), findsOneWidget);
        expect(find.text('Setujui syarat terlebih dahulu.'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          tester.widget<Semantics>(summary('signup')).properties.liveRegion,
          isTrue,
        );
      },
    );
  }

  testWidgets('login memperbarui error tanpa menghapus isian', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));
    final normal = input(tester, 'login-identifier').decoration!.fillColor;
    await submitLogin(tester);
    await fillLogin(tester, 'identifier', 'attar_rais');
    expect(summary('login'), findsOneWidget);
    expect(find.text('Isi email atau username.'), findsNothing);
    expect(input(tester, 'login-identifier').decoration!.fillColor, normal);
    await fillLogin(tester, 'password', 'lama');
    expect(summary('login'), findsNothing);
    expect(find.text('Isi kata sandi.'), findsNothing);
    expect(input(tester, 'login-identifier').controller!.text, 'attar_rais');
    await submitLogin(tester);
    expect(find.text('Login belum tersedia'), findsOneWidget);
  });

  testWidgets(
    'register hanya menyorot kolom salah dan pulih setelah diperbaiki',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      final normal = input(tester, 'signup-email').decoration!.fillColor;
      await fillValidForm(tester);
      await acceptTerms(tester);
      await fillField(tester, 'email', 'email.tidak.valid');
      await fillField(tester, 'confirmation', 'Berbeda42!');
      await submitForm(tester);
      expect(summary('signup'), findsOneWidget);
      expect(
        input(tester, 'signup-email').decoration!.fillColor,
        isNot(normal),
      );
      expect(input(tester, 'signup-name').decoration!.fillColor, normal);
      expect(find.text('Kata sandi belum cocok.'), findsOneWidget);

      await fillField(tester, 'email', 'attar@example.com');
      expect(summary('signup'), findsOneWidget);
      expect(find.text('Masukkan email yang valid.'), findsNothing);
      expect(input(tester, 'signup-email').decoration!.fillColor, normal);
      await fillField(tester, 'confirmation', 'DapurKuy42!');
      expect(summary('signup'), findsNothing);
      expect(find.text('Kata sandi belum cocok.'), findsNothing);
      expect(input(tester, 'signup-name').controller!.text, 'Attar Rais');
    },
  );

  testWidgets('persetujuan dan perubahan password memperbarui error register', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await fillValidForm(tester);
    await submitForm(tester);
    expect(summary('signup'), findsOneWidget);
    await acceptTerms(tester);
    expect(summary('signup'), findsNothing);

    await fillField(tester, 'password', 'DapurBaru42!');
    expect(summary('signup'), findsOneWidget);
    expect(find.text('Kata sandi belum cocok.'), findsOneWidget);
    await fillField(tester, 'confirmation', 'DapurBaru42!');
    expect(summary('signup'), findsNothing);
  });

  for (final page in ['login', 'signup']) {
    testWidgets('$page mengarahkan layar kecil ke ringkasan error', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: page == 'login' ? const AkunPage() : const SignupPage(),
        ),
      );
      if (page == 'login') {
        await submitLogin(tester);
      } else {
        await submitForm(tester);
      }
      expect(summary(page).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
