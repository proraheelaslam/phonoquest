import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/app_config.dart';

const String _productionApiBaseUrl = 'https://api.schoolhouse.cloud/api/v1';

/// API root guaranteed to include scheme + host (needed for Flutter web media).
Uri get apiBaseUri {
  final parsed = Uri.tryParse(AppConfig.apiBaseUrl);
  if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
    return parsed;
  }
  return Uri.parse(_productionApiBaseUrl);
}

/// Normalizes API media paths to an absolute http(s) URL.
String resolveMediaUrl(String? url) {
  final trimmed = url?.trim() ?? '';
  if (trimmed.isEmpty) return trimmed;

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    return trimmed;
  }

  if (trimmed.startsWith('/')) {
    final base = apiBaseUri;
    return base.replace(path: trimmed).toString();
  }

  return trimmed;
}

/// Rewrites remote media URLs through the API proxy so Flutter web can load
/// images/audio from `api.schoolhouse.cloud` without browser CORS blocks.
String proxiedMediaUrl(String? url) {
  final trimmed = resolveMediaUrl(url);
  if (trimmed.isEmpty) return trimmed;

  if (trimmed.contains('/phonics/media-proxy')) {
    return ensureAbsoluteMediaUrl(trimmed);
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) {
    return trimmed;
  }

  final base = apiBaseUri;
  final sameApiHost = uri.scheme == base.scheme && uri.host == base.host;
  if (!kIsWeb && sameApiHost) {
    return trimmed;
  }

  final proxyPath = _joinUrlPath(base.path, 'phonics/media-proxy');
  return base
      .replace(
        path: proxyPath,
        queryParameters: {'url': trimmed},
      )
      .toString();
}

/// Ensures [url] is absolute. Relative `/api/v1/...` paths are resolved against [apiBaseUri].
String ensureAbsoluteMediaUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  final parsed = Uri.tryParse(trimmed);
  if (parsed == null) return trimmed;
  if (parsed.hasScheme && parsed.host.isNotEmpty) return trimmed;

  final base = apiBaseUri;
  return base.replace(path: parsed.path, query: parsed.query).toString();
}

/// Image load order: proxied URL on web (CORS-safe); direct first on mobile.
List<String> imageMediaCandidates(String? url) {
  final resolved = resolveMediaUrl(url);
  if (resolved.isEmpty) return const [];

  final proxied = proxiedMediaUrl(resolved);
  if (kIsWeb) {
    if (proxied == resolved) return [resolved];
    return [proxied, resolved];
  }
  if (proxied == resolved) {
    return [resolved];
  }
  return [resolved, proxied];
}

/// URL candidates for [just_audio] on the current platform (direct CDN first on web).
List<String> playbackMediaCandidates(String? url) {
  final trimmed = resolveMediaUrl(url);
  if (trimmed.isEmpty) return const [];

  final proxied = proxiedMediaUrl(trimmed);
  if (kIsWeb) {
    return [trimmed, proxied];
  }
  return [proxied, trimmed];
}

String _joinUrlPath(String basePath, String segment) {
  final clean = basePath.endsWith('/')
      ? basePath.substring(0, basePath.length - 1)
      : basePath;
  return '$clean/$segment';
}

bool isNetworkMediaUrl(String? value) {
  final uri = Uri.tryParse(resolveMediaUrl(value));
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}
