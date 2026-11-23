import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/akun/screens/signup_page.dart';

void main() {
  testWidgets('register memuat kelima isian dan tombol utama', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('TAKARKUY'), findsOneWidget);
    for (final label in [
      'Nama Lengkap',
      'Username',
      'Email',
      'Kata Sandi',
      'Konfirmasi Kata Sandi',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.widgetWithText(FilledButton, 'DaftarKuy'), findsOneWidget);
    final email = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('signup-email')),
        matching: find.byType(TextField),
      ),
    );
    expect(email.keyboardType, TextInputType.emailAddress);
  });

  for (final brightness in Brightness.values) {
    testWidgets('register mengikuti tema ${brightness.name}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const SignupPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        brightness == Brightness.dark
            ? const Color(0xFF0F1713)
            : const Color(0xFFE9FFF4),
      );
      final action = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'DaftarKuy'),
      );
      expect(
        action.style!.backgroundColor!.resolve({}),
        brightness == Brightness.dark
            ? const Color(0xFFD4F45A)
            : const Color(0xFF007452),
      );
    });
  }

  testWidgets('form tetap dapat digulir saat keyboard terbuka di HP', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const SignupPage(),
      ),
    );

    final action = find.widgetWithText(FilledButton, 'DaftarKuy');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(action.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
