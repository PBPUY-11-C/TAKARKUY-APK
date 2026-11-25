import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/app/menu_page.dart';
import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/api/api_config.dart';
import 'package:takarkuy_apk/main.dart';

import '../../support/fake_cookie_request.dart';

void main() {
  test('alamat server bawaan adalah PWS dan path digabung tanpa garis miring ganda', () {
    expect(ApiConfig.baseUrl, 'https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id');
    expect(ApiConfig.url('/api/planner/plans/'),
        'https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id/api/planner/plans/');
  });

  test('get mengembalikan JSON dari path yang diminta', () async {
    final request = FakeCookieRequest({
      'GET /api/planner/plans/': [
        {'id': 'a1', 'title': 'Minggu ini'},
      ],
    });

    final data = await ApiClient(request).get('/api/planner/plans/');

    expect(data, [
      {'id': 'a1', 'title': 'Minggu ini'},
    ]);
    expect(request.calls.single.method, 'GET');
  });

  test('post mengirim body sebagai JSON', () async {
    final request = FakeCookieRequest({'POST /api/planner/plans/': {'id': 'a1'}});

    await ApiClient(request).post('/api/planner/plans/', {'budget': '150000', 'days': 3});

    expect(jsonDecode(request.calls.single.body! as String), {'budget': '150000', 'days': 3});
  });

  test('jawaban error dari server menjadi ApiException dengan pesan dan kode', () async {
    final request = FakeCookieRequest({
      'POST /api/planner/plans/': {
        'error': 'Budget belum cukup.',
        'code': 'invalid',
        'fields': {'budget': ['Terlalu kecil.']},
      },
    });

    final error = await ApiClient(request)
        .post('/api/planner/plans/', {})
        .then<ApiException?>((_) => null, onError: (Object e) => e as ApiException);

    expect(error!.message, 'Budget belum cukup.');
    expect(error.code, 'invalid');
    expect(error.fields, {'budget': ['Terlalu kecil.']});
  });

  test('jawaban yang bukan JSON menjadi pesan yang dipahami pengguna', () async {
    final request = FakeCookieRequest({'GET /api/x/': const FormatException('bukan json')});

    expect(
      () => ApiClient(request).get('/api/x/'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'bad_response')),
    );
  });

  test('koneksi putus menjadi pesan yang dipahami pengguna', () async {
    final request = FakeCookieRequest({'GET /api/x/': http.ClientException('offline')});

    expect(
      () => ApiClient(request).get('/api/x/'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'network')),
    );
  });

  testWidgets('aplikasi menyediakan CookieRequest dan ApiClient yang sama untuk semua modul',
      (tester) async {
    final request = FakeCookieRequest();
    await tester.pumpWidget(TakarKuyApp(request: request));
    final context = tester.element(find.byType(MenuPage));

    expect(context.read<CookieRequest>(), same(request));
    expect(context.read<ApiClient>().request, same(request));
  });
}
