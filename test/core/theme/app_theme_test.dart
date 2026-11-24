import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/core/theme/app_colors.dart';
import 'package:takarkuy_apk/core/theme/app_theme.dart';
import 'package:takarkuy_apk/main.dart';

void main() {
  test('warna inti sama dengan design system web', () {
    expect(AppColors.green, const Color(0xFF0F3D2E));
    expect(AppColors.lime, const Color(0xFFD4F45A));
    expect(AppColors.canvas, const Color(0xFFF2F8F4));
    expect(AppColors.ink, const Color(0xFF10251C));
  });

  test('tema terang memakai hijau TAKARKUY sebagai warna utama', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.green);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.appBarTheme.backgroundColor, AppColors.green);
    expect(theme.appBarTheme.foregroundColor, Colors.white);
  });

  testWidgets('aplikasi memakai tema bersama', (tester) async {
    await tester.pumpWidget(const TakarKuyApp());
    final context = tester.element(find.byType(Scaffold).first);

    expect(Theme.of(context).colorScheme.primary, AppColors.green);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.canvas);
  });
}
