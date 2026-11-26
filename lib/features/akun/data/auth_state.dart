import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';

/// Status autentikasi akun aplikasi, sekaligus sumber pembaruan untuk route guard.
class AuthState extends ChangeNotifier {
  static const _tokenKey = 'takarkuy.auth.token';
  static const _usernameKey = 'takarkuy.auth.username';

  AuthState(this.api, {this.username, String? token}) : _token = token {
    api.token = token;
  }

  final ApiClient api;
  String? username;
  String? _token;
  String? error;
  Map<String, String> fieldErrors = {};
  Map<String, dynamic>? profile;
  bool isLoading = false;
  bool profileLoading = true;
  String? profileError;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<bool> login(
    String identifier,
    String password, {
    bool rememberMe = false,
  }) async {
    _startRequest();
    try {
      final response = await api.post('/api/auth/login/', {
        'username': identifier.trim(),
        'password': password,
      });
      if (response is! Map ||
          response['status'] != true ||
          response['token'] is! String) {
        throw const ApiException(
          'Server belum memberikan token login.',
          code: 'bad_response',
        );
      }
      _token = response['token'] as String;
      api.token = _token;
      username = response['username'] as String? ?? identifier.trim();
      final preferences = await _preferences();
      if (preferences != null) {
        if (rememberMe) {
          await preferences.setString(_tokenKey, _token!);
          await preferences.setString(_usernameKey, username!);
        } else {
          await preferences.remove(_tokenKey);
          await preferences.remove(_usernameKey);
        }
      }
      notifyListeners();
      return true;
    } on ApiException catch (exception) {
      _captureError(exception);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> fields) async {
    _startRequest();
    try {
      final response = await api.post('/api/auth/register/', fields);
      if (response is! Map || response['status'] != true) {
        throw const ApiException(
          'Pendaftaran belum berhasil.',
          code: 'bad_response',
        );
      }
      return true;
    } on ApiException catch (exception) {
      _captureError(exception);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadProfile() async {
    if (!isAuthenticated) return false;
    profileLoading = true;
    profileError = null;
    notifyListeners();
    try {
      final response = await api.get('/api/auth/profile/');
      if (response is! Map) {
        throw const ApiException(
          'Data profil tidak dikenali.',
          code: 'bad_response',
        );
      }
      profile = Map<String, dynamic>.from(response);
      return true;
    } on ApiException catch (exception) {
      profileError = exception.message;
      if (exception.code == 'not_authenticated') _clearAuthentication();
      return false;
    } finally {
      profileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _startRequest();
    try {
      if (isAuthenticated) await api.post('/api/auth/logout/', const {});
      error = null;
      return true;
    } on ApiException catch (exception) {
      _captureError(exception);
      return false;
    } finally {
      _clearAuthentication();
      final preferences = await _preferences();
      await preferences?.remove(_tokenKey);
      await preferences?.remove(_usernameKey);
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    fieldErrors = {};
    notifyListeners();
  }

  Future<void> restoreSession() async {
    if (isAuthenticated) return;
    final preferences = await _preferences();
    if (preferences == null) return;
    final savedToken = preferences.getString(_tokenKey);
    if (savedToken == null || savedToken.isEmpty) return;
    _token = savedToken;
    api.token = savedToken;
    username = preferences.getString(_usernameKey);
    notifyListeners();
  }

  Future<SharedPreferences?> _preferences() async {
    try {
      return await SharedPreferences.getInstance();
    } on Object {
      // Login remains usable when a platform has no preferences plugin registered.
      return null;
    }
  }

  void _startRequest() {
    error = null;
    fieldErrors = {};
    isLoading = true;
    notifyListeners();
  }

  void _captureError(ApiException exception) {
    error = exception.message;
    final entries =
        exception.fields?.entries ?? const <MapEntry<String, dynamic>>[];
    fieldErrors = {
      for (final entry in entries) entry.key: _firstMessage(entry.value),
    };
  }

  String _firstMessage(dynamic value) {
    while (value is List && value.isNotEmpty) {
      value = value.first;
    }
    if (value is Map && value['message'] != null)
      return value['message'].toString();
    return value?.toString() ?? 'Periksa kembali isian ini.';
  }

  void _clearAuthentication() {
    _token = null;
    username = null;
    profile = null;
    api.token = null;
  }
}
