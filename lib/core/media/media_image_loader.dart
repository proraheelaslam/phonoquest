import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../network/api_request_coordinator.dart';
import 'media_url.dart';

/// Shared in-memory loader for remote lesson images (dedupes + caches bytes).
class MediaImageLoader {
  MediaImageLoader._();

  static final Map<String, Uint8List> _bytesCache = {};
  static final Map<String, Future<Uint8List?>> _inFlight = {};

  static const Duration _cacheTtl = Duration(hours: 12);

  static Future<Uint8List?> loadBytes(String? url) async {
    final candidates = imageMediaCandidates(url);
    if (candidates.isEmpty) return null;

    for (final source in candidates) {
      final cached = _bytesCache[source];
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      final pending = _inFlight[source];
      if (pending != null) {
        final shared = await pending;
        if (shared != null && shared.isNotEmpty) {
          return shared;
        }
        continue;
      }

      final future = _fetch(source);
      _inFlight[source] = future;
      try {
        final bytes = await future;
        if (bytes != null && bytes.isNotEmpty) {
          _bytesCache[source] = bytes;
          return bytes;
        }
      } finally {
        _inFlight.remove(source);
      }
    }

    return null;
  }

  static Future<Uint8List?> _fetch(String source) async {
    final cacheKey = ApiRequestCoordinator.cacheKey('GET', source);
    try {
      final response = await ApiRequestCoordinator.runGet(
        cacheKey,
        () => http.get(Uri.parse(source)).timeout(const Duration(seconds: 15)),
        cacheTtl: _cacheTtl,
        useCache: !_isAvatarUrl(source),
      );
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static void clearCache() {
    _bytesCache.clear();
    _inFlight.clear();
  }

  static bool _isAvatarUrl(String source) {
    return source.contains('/media/avatars/') ||
        source.contains('media-proxy') && source.contains('%2Fmedia%2Favatars%2F');
  }
}
