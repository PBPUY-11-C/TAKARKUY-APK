import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  testWidgets('pintasan Meal Planner di Dashboard membuka halaman Planner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.tap(find.text('Meal Planner'));
    await tester.pumpAndSettle();

    expect(find.byType(PlannerPage), findsOneWidget);
  });

  testWidgets('pintasan Pantry di Dashboard membuka halaman Pantry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.tap(find.text('Pantry'));
    await tester.pumpAndSettle();

    expect(find.byType(PantryPage), findsOneWidget);
  });
}
