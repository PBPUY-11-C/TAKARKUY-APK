import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.fields});

  final String message;
  final String? code;
  final Map<String, dynamic>? fields;

  @override
  String toString() => message;
}

/// Klien JSON bersama. Token aktif otomatis dikirim sebagai `Authorization: Token ...`.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;
  String? token;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body: body);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    final activeToken = token;
    if (activeToken != null && activeToken.isNotEmpty) {
      headers['Authorization'] = 'Token $activeToken';
    }
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      final response = await http.Response.fromStream(
        await _client.send(request),
      );
      dynamic data;
      if (response.body.trim().isNotEmpty) {
        try {
          data = jsonDecode(utf8.decode(response.bodyBytes));
        } on FormatException {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            throw const ApiException(
              'Server mengirim jawaban yang tidak dikenali. Coba lagi nanti.',
              code: 'bad_response',
            );
          }
          data = null;
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final map = data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};
        throw ApiException(
          map['error'] as String? ??
              map['message'] as String? ??
              'Permintaan gagal (${response.statusCode}). Coba lagi.',
          code: map['code'] as String? ?? 'http_${response.statusCode}',
          fields: map['fields'] is Map
              ? Map<String, dynamic>.from(map['fields'] as Map)
              : null,
        );
      }
      return data ?? <String, dynamic>{};
    } on http.ClientException {
      throw const ApiException(
        'Tidak bisa terhubung ke server. Periksa koneksi internetmu.',
        code: 'network',
      );
    }
  }

  void close() => _client.close();
}
