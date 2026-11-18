import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/akun/screens/akun_page.dart';

void main() {
  testWidgets('halaman Akun menampilkan judul Akun', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AkunPage()));

    expect(find.text('Akun'), findsWidgets);
  });
}
