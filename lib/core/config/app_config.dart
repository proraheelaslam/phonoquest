import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

/// Production API: [https://api.schoolhouse.cloud/api/v1](https://api.schoolhouse.cloud/api/v1)
abstract final class AppConfig {
  static const String productionApiBaseUrl = 'https://api.schoolhouse.cloud/api/v1';

  /// Local FastAPI — only when explicitly passed:
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1`
  static const String localApiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  /// Resolved API root (`/api/v1` included). Never empty.
  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.trim().isNotEmpty) {
      return _normalizeBaseUrl(env);
    }
    return productionApiBaseUrl;
  }

  static String _normalizeBaseUrl(String raw) {
    var url = raw.trim().replaceAll(RegExp(r'/+$'), '');
    // Accept bare host e.g. https://api.schoolhouse.cloud → append /api/v1
    if (!url.endsWith('/api/v1')) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.hasScheme && !uri.path.contains('/api/v1')) {
        url = '$url/api/v1';
      }
    }
    return url;
  }

  /// Path prefix for endpoints (empty when [apiBaseUrl] already includes `/api/v1`).
  static const String apiPrefix = '';

  /// Debug helper — log resolved base in dev tools.
  static void debugLogBaseUrl() {
    if (kDebugMode) {
      // ignore: avoid_print
      print('PhonoQuest API base: $apiBaseUrl (web=$kIsWeb)');
    }
  }
}
