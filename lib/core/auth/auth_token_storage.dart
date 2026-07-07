import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth tokens from `/auth/login` (and future flows) for `Authorization` headers.
class AuthTokenStorage {
  AuthTokenStorage._();

  static final AuthTokenStorage instance = AuthTokenStorage._();

  static const _keyAccess = 'phonoquest_access_token';
  static const _keyType = 'phonoquest_token_type';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveSession({
    required String accessToken,
    required String tokenType,
  }) async {
    final p = await _prefs;
    await p.setString(_keyAccess, accessToken);
    await p.setString(_keyType, tokenType);
  }

  Future<String?> readAccessToken() async {
    final p = await _prefs;
    final v = p.getString(_keyAccess);
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Future<String?> readTokenType() async {
    final p = await _prefs;
    return p.getString(_keyType);
  }

  Future<void> clear() async {
    final p = await _prefs;
    await p.remove(_keyAccess);
    await p.remove(_keyType);
  }
}
