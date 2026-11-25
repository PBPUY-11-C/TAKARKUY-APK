import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';

void main() {
  test('Ingat saya menyimpan dan memulihkan token lokal', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'status': true,
          'username': 'attarrais',
          'token': 'persisted-token',
        }),
        200,
      ),
    );
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');
    final auth = AuthState(api);

    expect(
      await auth.login('attarrais', 'Rahasia!123', rememberMe: true),
      isTrue,
    );
    final restored = AuthState(
      ApiClient(client: client, baseUrl: 'http://localhost:8000'),
    );
    await restored.restoreSession();

    expect(restored.token, 'persisted-token');
    expect(restored.username, 'attarrais');
  });

  test('login menyimpan token dan username dari server', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({
          'status': true,
          'username': 'attarrais',
          'token': 'abc123',
        }),
        200,
      );
    });
    final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');
    final auth = AuthState(api);

    expect(await auth.login('attar@example.com', 'Rahasia!123'), isTrue);

    expect(auth.isAuthenticated, isTrue);
    expect(auth.username, 'attarrais');
    expect(api.token, 'abc123');
    expect(jsonDecode(sent.body), {
      'username': 'attar@example.com',
      'password': 'Rahasia!123',
    });
  });

  test('login menyimpan pesan dan error per field dari server', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': 'Periksa formulir.',
          'code': 'invalid',
          'fields': {
            'username': ['Username tidak ditemukan.'],
          },
        }),
        400,
      ),
    );
    final auth = AuthState(
      ApiClient(client: client, baseUrl: 'http://localhost:8000'),
    );

    expect(await auth.login('salah', 'salah'), isFalse);

    expect(auth.isAuthenticated, isFalse);
    expect(auth.error, 'Periksa formulir.');
    expect(auth.fieldErrors['username'], 'Username tidak ditemukan.');
  });

  test(
    'register mengirim semua data dan logout mencabut token lokal',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/register/')) {
          return http.Response(
            jsonEncode({'status': true, 'username': 'attarrais'}),
            201,
          );
        }
        return http.Response('', 204);
      });
      final api = ApiClient(client: client, baseUrl: 'http://localhost:8000');
      final auth = AuthState(api, username: 'attarrais', token: 'abc123');

      expect(
        await auth.register({
          'full_name': 'Attar Rais',
          'username': 'attarrais',
          'email': 'attar@example.com',
          'password1': 'Rahasia!123',
          'password2': 'Rahasia!123',
        }),
        isTrue,
      );
      api.token = 'abc123';
      expect(await auth.logout(), isTrue);

      expect(requests.first.url.path, '/api/auth/register/');
      expect(jsonDecode(requests.first.body)['full_name'], 'Attar Rais');
      expect(requests.last.headers['authorization'], 'Token abc123');
      expect(auth.isAuthenticated, isFalse);
      expect(api.token, isNull);
    },
  );

  test(
    'profile mengirim Authorization Token dan menyimpan data server',
    () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({'username': 'attarrais', 'full_name': 'Attar Rais'}),
          200,
        );
      });
      final api = ApiClient(client: client, baseUrl: 'http://localhost:8000')
        ..token = 'abc123';
      final auth = AuthState(api, username: 'attarrais', token: 'abc123');

      expect(await auth.loadProfile(), isTrue);

      expect(sent.headers['authorization'], 'Token abc123');
      expect(auth.profile?['full_name'], 'Attar Rais');
    },
  );
}
