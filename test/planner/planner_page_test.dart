import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/planner/planner_page.dart';

void main() {
  testWidgets('halaman Planner menampilkan judul Planner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlannerPage()));

    expect(find.text('Planner'), findsWidgets);
  });
}
