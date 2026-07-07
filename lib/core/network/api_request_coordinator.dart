import 'package:http/http.dart' as http;

/// Coalesces identical in-flight GET requests and caches short-lived responses
/// to prevent request storms when tabs remount or widgets rebuild.
class ApiRequestCoordinator {
  ApiRequestCoordinator._();

  static final Map<String, Future<http.Response>> _inFlight = {};
  static final Map<String, _CacheEntry> _cache = {};
  static int _cacheGeneration = 0;

  static const Duration defaultCacheTtl = Duration(minutes: 5);

  static String cacheKey(String method, String url, {String? authToken}) {
    final tokenKey = authToken == null || authToken.isEmpty ? 'anon' : 'auth';
    return '$method::$url::$tokenKey';
  }

  static Future<http.Response> runGet(
    String key,
    Future<http.Response> Function() request, {
    Duration cacheTtl = defaultCacheTtl,
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = _cache[key];
      if (cached != null && !cached.isExpired && cached.generation == _cacheGeneration) {
        return cached.response;
      }
      final inFlight = _inFlight[key];
      if (inFlight != null) {
        return inFlight;
      }
    }

    final generationAtStart = _cacheGeneration;
    final future = request();
    if (useCache) {
      _inFlight[key] = future;
    }

    try {
      final response = await future;
      if (useCache &&
          response.statusCode == 200 &&
          generationAtStart == _cacheGeneration) {
        _cache[key] = _CacheEntry(
          response,
          DateTime.now().add(cacheTtl),
          generationAtStart,
        );
      } else if (useCache && response.statusCode >= 400) {
        _cache.remove(key);
      }
      return response;
    } finally {
      if (useCache) {
        _inFlight.remove(key);
      }
    }
  }

  static void invalidate({String? pathContains}) {
    _cacheGeneration++;
    if (pathContains == null || pathContains.isEmpty) {
      _cache.clear();
      _inFlight.clear();
      return;
    }
    _cache.removeWhere((key, _) => key.contains(pathContains));
    _inFlight.removeWhere((key, _) => key.contains(pathContains));
  }

  static void clearAll() {
    _cache.clear();
    _inFlight.clear();
  }
}

class _CacheEntry {
  _CacheEntry(this.response, this.expiresAt, this.generation);

  final http.Response response;
  final DateTime expiresAt;
  final int generation;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
