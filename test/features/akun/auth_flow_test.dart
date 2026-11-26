import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takarkuy_apk/main.dart';

import 'login_validation_test.dart' show fillLogin;
import 'signup_validation_test.dart' show fillValidForm, submitForm;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('login valid menyimpan token dan membuka dashboard', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'status': true,
          'username': 'attarrais',
          'token': 'token-123',
        }),
        200,
      ),
    );
    await tester.pumpWidget(TakarKuyApp(client: client));
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    await fillLogin(tester, 'identifier', 'attarrais');
    await fillLogin(tester, 'password', 'DapurKuy42!');
    await tester.ensureVisible(find.text('MasukKuy'));
    await tester.tap(find.text('MasukKuy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('error server saat register ditampilkan di kolom yang tepat', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': 'Username sudah digunakan.',
          'code': 'invalid',
          'fields': {
            'username': [
              {'message': 'Username sudah digunakan.'},
            ],
          },
        }),
        400,
      ),
    );
    await tester.pumpWidget(TakarKuyApp(client: client));
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DaftarKuy'));
    await tester.pumpAndSettle();
    await fillValidForm(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await submitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Username sudah digunakan.'), findsWidgets);
    expect(find.text('Pendaftaran belum tersedia'), findsNothing);
  });
}
