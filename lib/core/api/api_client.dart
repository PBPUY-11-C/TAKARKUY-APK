import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'api_config.dart';

/// Error API dengan pesan yang siap ditampilkan ke pengguna. `code` mengikuti server
/// (mis. `invalid`, `not_authenticated`), atau `network`/`bad_response` dari sisi aplikasi.
class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.fields});

  final String message;
  final String? code;

  /// Error per kolom form dari server, mis. `{'budget': ['Terlalu kecil.']}`.
  final Map<String, dynamic>? fields;

  @override
  String toString() => message;
}

/// Pintu tunggal semua modul ke API Django: memakai cookie login dari CookieRequest dan
/// mengubah setiap kegagalan menjadi ApiException.
class ApiClient {
  ApiClient(this.request);

  final CookieRequest request;

  Future<dynamic> get(String path) => _send(() => request.get(ApiConfig.url(path)));

  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _send(() => request.postJson(ApiConfig.url(path), jsonEncode(body)));

  static Future<dynamic> _send(Future<dynamic> Function() call) async {
    final dynamic data;
    try {
      data = await call();
    } on FormatException {
      throw const ApiException('Server mengirim jawaban yang tidak dikenali. Coba lagi nanti.',
          code: 'bad_response');
    } on http.ClientException {
      throw const ApiException('Tidak bisa terhubung ke server. Periksa koneksi internetmu.',
          code: 'network');
    }
    if (data is Map && data['error'] is String) {
      throw ApiException(
        data['error'] as String,
        code: data['code'] as String?,
        fields: data['fields'] is Map ? Map<String, dynamic>.from(data['fields'] as Map) : null,
      );
    }
    return data;
  }
}
