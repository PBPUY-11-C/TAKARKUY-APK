import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takarkuy_apk/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/akun/screens/signup_page.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('palet login dan register sama pada ${brightness.name}', (
      tester,
    ) async {
      Future<Map<String, Color?>> palette(Widget page) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: page,
          ),
        );
        await tester.pumpAndSettle();
        final field = tester.widget<TextField>(find.byType(TextField).first);
        final decoration = field.decoration!;
        final action = tester.widget<FilledButton>(find.byType(FilledButton));
        final visibility = tester.widget<Icon>(
          find.byIcon(Icons.visibility_outlined).first,
        );
        return {
          'latar': tester
              .widget<Scaffold>(find.byType(Scaffold))
              .backgroundColor,
          'isian': decoration.fillColor,
          'teks': field.style!.color,
          'placeholder': decoration.hintStyle!.color,
          'garis': decoration.enabledBorder!.borderSide.color,
          'fokus': decoration.focusedBorder!.borderSide.color,
          'error': decoration.errorStyle!.color,
          'ikon sandi':
              visibility.color ??
              IconTheme.of(tester.element(find.byWidget(visibility))).color,
          'tombol': action.style!.backgroundColor!.resolve({}),
          'teks tombol': action.style!.foregroundColor!.resolve({}),
        };
      }

      final login = await palette(const AkunPage());
      final signup = await palette(const SignupPage());
      expect(signup, login);
    });

    for (final width in [360.0, 800.0]) {
      testWidgets(
        'posisi navigasi dan identitas konsisten pada ${brightness.name} $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          Future<List<Rect>> measure(Widget page, String firstField) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(brightness: brightness),
                home: page,
              ),
            );
            await tester.pumpAndSettle();
            final back = find.byIcon(Icons.arrow_back);
            final theme = find.byTooltip(
              brightness == Brightness.dark
                  ? 'Gunakan mode terang'
                  : 'Gunakan mode gelap',
            );
            expect(back.hitTestable(), findsOneWidget);
            expect(theme.hitTestable(), findsOneWidget);
            final themeBounds = tester.getRect(theme);
            expect(themeBounds.width, greaterThanOrEqualTo(48));
            expect(themeBounds.height, greaterThanOrEqualTo(48));
            expect(themeBounds.center.dx, greaterThan(width / 2));
            expect(tester.takeException(), isNull);
            return [
              tester.getRect(back),
              themeBounds,
              tester.getRect(find.text('TAKARKUY')),
              tester.getRect(find.byKey(ValueKey(firstField))),
            ];
          }

          final login = await measure(const AkunPage(), 'login-identifier');
          final signup = await measure(const SignupPage(), 'signup-name');
          for (var index = 0; index < 3; index++) {
            expect(signup[index], login[index]);
          }
          expect(signup.last.left, login.last.left);
          expect(signup.last.right, login.last.right);
        },
      );
    }
  }

  testWidgets('register tidak meluap dengan teks besar di layar kecil', (
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
