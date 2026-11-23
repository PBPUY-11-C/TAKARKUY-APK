import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/akun/screens/akun_page.dart';

void main() {
  testWidgets('login menampilkan formulir sesuai desain', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));

    expect(find.text('MasukKuy'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke akunmu untuk lanjut memasak.'), findsOneWidget);
    expect(find.text('TAKARKUY'), findsOneWidget);
    expect(find.text('Email atau Username'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Ingat saya'), findsOneWidget);
    expect(find.text('DaftarKuy'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'MasukKuy'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('login memakai warna tema ${brightness.name}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const AkunPage(),
        ),
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        brightness == Brightness.dark
            ? const Color(0xFF0F1713)
            : const Color(0xFFE9FFF4),
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'MasukKuy'),
      );
      expect(
        button.style!.backgroundColor!.resolve({}),
        brightness == Brightness.dark
            ? const Color(0xFFD4F45A)
            : const Color(0xFF007452),
      );
    });
  }

  testWidgets(
    'login dapat dipakai dengan keyboard dan teks besar di HP kecil',
    (tester) async {
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
          home: const AkunPage(),
        ),
      );
      final button = find.widgetWithText(FilledButton, 'MasukKuy');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(button.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
