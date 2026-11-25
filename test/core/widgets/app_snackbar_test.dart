import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/core/theme/app_colors.dart';
import 'package:takarkuy_apk/core/widgets/app_snackbar.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return context;
  }

  testWidgets('pesan error memakai warna bahaya', (tester) async {
    final context = await pumpHost(tester);
    showAppSnackBar(context, 'Gagal menyimpan.', error: true);
    await tester.pump();

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(find.text('Gagal menyimpan.'), findsOneWidget);
    expect(bar.backgroundColor, AppColors.danger);
  });

  testWidgets('tombol aksi (mis. Batal) memanggil callback', (tester) async {
    final context = await pumpHost(tester);
    var undone = false;
    showAppSnackBar(
      context,
      'Rencana dihapus.',
      actionLabel: 'Batal',
      onAction: () => undone = true,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Batal'));
    expect(undone, isTrue);
  });

  testWidgets('pesan baru menggantikan pesan lama', (tester) async {
    final context = await pumpHost(tester);
    showAppSnackBar(context, 'Pertama');
    showAppSnackBar(context, 'Kedua');
    await tester.pumpAndSettle();

    expect(find.text('Kedua'), findsOneWidget);
    expect(find.text('Pertama'), findsNothing);
  });
}
