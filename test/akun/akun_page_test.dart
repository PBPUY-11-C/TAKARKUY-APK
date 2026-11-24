import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/akun/screens/akun_page.dart';

void main() {
  testWidgets('kerangka Akun menampilkan halaman login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));

    expect(find.text('MasukKuy'), findsOneWidget);
    expect(find.text('Halaman Login'), findsOneWidget);
    expect(find.text('Buka halaman daftar'), findsOneWidget);
  });
}
