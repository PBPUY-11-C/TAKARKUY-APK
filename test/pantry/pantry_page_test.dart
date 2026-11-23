import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/pantry/pantry_page.dart';

void main() {
  testWidgets('halaman Pantry menampilkan judul Pantry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantryPage()));

    expect(find.text('Stok Dapur'), findsWidgets);
  });
}
