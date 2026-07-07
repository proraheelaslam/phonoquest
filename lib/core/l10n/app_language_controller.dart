import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/api_error_parser.dart';
import '../network/api_exception.dart';
import 'app_locale.dart';
import 'app_translation_maps.dart';
import 'app_translations.dart';

class AppLanguageController extends ChangeNotifier {
  AppLanguageController._();

  static final AppLanguageController instance = AppLanguageController._();

  String _code = AppLocale.en;
  int? _activeUserId;
  bool _initialized = false;

  String get code => _code;
  int? get activeUserId => _activeUserId;
  Locale get flutterLocale => AppLocale.toFlutterLocale(_code);
  AppTranslations get strings => AppTranslations(_code);
  String get displayLabel => AppLocale.displayName(_code);
  bool get isInitialized => _initialized;

  static String prefsKeyFor(int? userId) {
    if (userId == null) return 'phonoquest_locale_guest';
    return 'phonoquest_locale_u_$userId';
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _code = AppLocale.en;
    _initialized = true;
    notifyListeners();
  }

  Future<void> bindUser({
    required int userId,
    String? serverLocale,
    bool notify = true,
  }) async {
    _activeUserId = userId;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final fromServer =
        serverLocale != null && serverLocale.trim().isNotEmpty
            ? AppLocale.normalize(serverLocale)
            : null;
    final cached = prefs.getString(prefsKeyFor(userId));
    final code = fromServer ?? cached ?? AppLocale.en;
    await _setCode(code, persistLocal: true, notify: notify);
  }

  Future<void> unbindUser({bool notify = true}) async {
    _activeUserId = null;
    await _setCode(AppLocale.en, persistLocal: false, notify: notify);
  }

  Future<void> applyCode(
    String code, {
    bool persistLocal = true,
    bool notify = true,
  }) async {
    final normalized = AppLocale.normalize(code);
    if (normalized == _code && _initialized) return;
    await _setCode(normalized, persistLocal: persistLocal, notify: notify);
  }

  Future<void> syncFromProfile({
    required int userId,
    String? locale,
  }) async {
    await bindUser(userId: userId, serverLocale: locale);
  }

  Future<bool> saveToServer(String code) async {
    if (_activeUserId == null) {
      throw ApiException(401, strings.signInRequired);
    }
    final normalized = AppLocale.normalize(code);
    try {
      final client = ApiClient();
      final response = await client.patchJson(
        '/profiles',
        {'locale': normalized},
        authorized: true,
      );
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode,
          parseApiErrorBody(response.body, fallback: strings.couldNotUpdateLanguage),
        );
      }
      ApiClient.clearRequestCache();
      await _setCode(normalized, persistLocal: true);
      return true;
    } on ApiException {
      rethrow;
    }
  }

  Future<void> _setCode(
    String normalized, {
    required bool persistLocal,
    bool notify = true,
  }) async {
    _code = normalized;
    _initialized = true;
    if (persistLocal) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKeyFor(_activeUserId), normalized);
    }
    if (notify) notifyListeners();
  }
}

extension AppLanguageContext on BuildContext {
  AppTranslations get t => AppLanguageController.instance.strings;

  /// Translate a static English UI literal for the active user locale.
  String tr(String english) => t.tr(english);
}
