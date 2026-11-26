import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/api/api_config.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';
import 'package:takarkuy_apk/main.dart';

void main() {
  test('alamat server bawaan adalah PWS dan path digabung tanpa garis miring ganda', () {
    expect(
      ApiConfig.baseUrl,
      'https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id',
    );
    expect(
      ApiConfig.url('/api/planner/plans/'),
      'https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id/api/planner/plans/',
    );
  });

  testWidgets('aplikasi menyediakan satu AuthState dan ApiClient bersama', (
    tester,
  ) async {
    final client = MockClient((_) async => http.Response('{}', 200));
    await tester.pumpWidget(TakarKuyApp(client: client));
    final context = tester.element(find.byType(Scaffold).first);

    expect(context.read<AuthState>().api, same(context.read<ApiClient>()));
  });

  test('GET mengirim header token dan membaca JSON', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode([
          {'id': 'a1'},
        ]),
        200,
      );
    });
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000')
      ..token = 'abc123';

    expect(await api.get('/api/planner/plans/'), [
      {'id': 'a1'},
    ]);
    expect(sent.headers['authorization'], 'Token abc123');
    expect(sent.url.path, '/api/planner/plans/');
  });

  test('POST mengirim JSON dan membaca data sukses', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(jsonEncode({'id': 'a1'}), 201);
    });
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');

    expect(await api.post('/api/planner/plans/', {'budget': 150000}), {
      'id': 'a1',
    });
    expect(sent.headers['content-type'], 'application/json');
    expect(jsonDecode(sent.body), {'budget': 150000});
  });

  test('error API menjadi ApiException termasuk error per field', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': 'Periksa data.',
          'code': 'invalid',
          'fields': {
            'email': ['Format email salah.'],
          },
        }),
        400,
      ),
    );
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');

    await expectLater(
      api.post('/api/auth/register/', {}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.message, 'message', 'Periksa data.')
            .having((error) => error.code, 'code', 'invalid')
            .having((error) => error.fields?['email'], 'fields', [
              'Format email salah.',
            ]),
      ),
    );
  });

  test('pesan login legacy dan respons kosong logout ditangani', () async {
    final client = MockClient(
      (request) async => request.url.path.endsWith('/login/')
          ? http.Response(
              jsonEncode({'status': false, 'message': 'Kata sandi salah.'}),
              401,
            )
          : http.Response('', 204),
    );
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');

    await expectLater(
      api.post('/api/auth/login/', {'username': 'attar', 'password': 'salah'}),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Kata sandi salah.',
        ),
      ),
    );
    expect(await api.post('/api/auth/logout/', const {}), isA<Map>());
  });

  test(
    'format tidak dikenal dan koneksi putus menjadi error yang ramah',
    () async {
      final invalidJson = ApiClient(
        client: MockClient((_) async => http.Response('<html>', 200)),
        baseUrl: 'http://localhost:8000',
      );
      final offline = ApiClient(
        client: MockClient(
          (_) => Future.error(http.ClientException('offline')),
        ),
        baseUrl: 'http://localhost:8000',
      );

      await expectLater(
        invalidJson.get('/api/x/'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'bad_response',
          ),
        ),
      );
      await expectLater(
        offline.get('/api/x/'),
        throwsA(
          isA<ApiException>().having((error) => error.code, 'code', 'network'),
        ),
      );
    },
  );
}
