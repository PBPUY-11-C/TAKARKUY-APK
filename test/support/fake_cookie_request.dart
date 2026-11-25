import 'package:pbp_django_auth/pbp_django_auth.dart';

/// Server palsu untuk tes: jawaban disiapkan per "METHOD /path", tiap panggilan dicatat.
/// Nilai jawaban yang berupa Exception akan dilempar, untuk menguji kondisi gagal.
///
/// Contoh:
///   final request = FakeCookieRequest({'GET /api/planner/plans/': []});
///   await tester.pumpWidget(TakarKuyApp(request: request));
class FakeCookieRequest extends CookieRequest {
  FakeCookieRequest([Map<String, Object?>? responses]) : responses = responses ?? {};

  final Map<String, Object?> responses;
  final List<({String method, String path, Object? body})> calls = [];

  @override
  Future<dynamic> get(String url) async => _reply('GET', url, null);

  @override
  Future<dynamic> post(String url, dynamic data) async => _reply('POST', url, data);

  @override
  Future<dynamic> postJson(String url, dynamic data) async => _reply('POST', url, data);

  @override
  Future<dynamic> login(String url, dynamic data) async {
    final reply = _reply('POST', url, data);
    loggedIn = reply is Map && reply['status'] == true;
    return reply;
  }

  @override
  Future<dynamic> logout(String url) async {
    loggedIn = false;
    return _reply('POST', url, null);
  }

  dynamic _reply(String method, String url, Object? body) {
    final uri = Uri.parse(url);
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    calls.add((method: method, path: path, body: body));
    final key = '$method $path';
    if (!responses.containsKey(key)) {
      throw StateError('Tidak ada jawaban palsu untuk "$key".');
    }
    final reply = responses[key];
    if (reply is Exception) throw reply;
    return reply;
  }
}
