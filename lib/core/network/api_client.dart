import 'dart:async';
import 'dart:convert';
import 'dart:io' show HandshakeException, HttpClient, SocketException;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:http_parser/http_parser.dart';

import '../auth/auth_token_storage.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_request_coordinator.dart';

/// Thin HTTP client for JSON APIs under [AppConfig.apiBaseUrl].
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    AuthTokenStorage? tokenStorage,
  })  : _http = httpClient ?? _createHttpClient(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), ''),
        _tokens = tokenStorage ?? AuthTokenStorage.instance {
    if (_baseUrl.isEmpty || !Uri.parse(_baseUrl).hasScheme) {
      throw ArgumentError('Invalid API_BASE_URL: "$_baseUrl"');
    }
  }

  final http.Client _http;
  final String _baseUrl;
  final AuthTokenStorage _tokens;

  static http.Client _createHttpClient() {
    if (kIsWeb) return http.Client();
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30);
    return http_io.IOClient(ioClient);
  }

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final p = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(_baseUrl);
    final uri = base.replace(
      path: '${base.path}$p'.replaceAll('//', '/'),
      queryParameters: queryParameters?.isNotEmpty == true ? queryParameters : null,
    );
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw ApiException(0, 'Invalid API configuration. Please reinstall the app.');
    }
    return uri;
  }

  Future<Map<String, String>> _jsonHeaders({required bool authorized}) async {
    const contentType = 'application/json; charset=utf-8';
    if (!authorized) {
      return const {'Content-Type': contentType, 'Accept': 'application/json'};
    }
    final token = await _tokens.readAccessToken();
    if (token == null || token.isEmpty) {
      return const {'Content-Type': contentType, 'Accept': 'application/json'};
    }
    return {
      'Content-Type': contentType,
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _execute(Future<http.Response> request) async {
    try {
      return await request.timeout(const Duration(seconds: 30));
    } on SocketException {
      throw ApiException(0, 'No internet connection. Please check your network and try again.');
    } on HandshakeException {
      throw ApiException(
        0,
        'Secure connection failed. Check your device date/time and try again.',
      );
    } on TimeoutException {
      throw ApiException(0, 'Connection timed out. Please try again.');
    } on http.ClientException catch (e) {
      final hint = kDebugMode
          ? (kIsWeb
              ? ' If login works in Postman but not here, the server may be returning an error without CORS headers — check GET /dashboard/parent on production.'
              : ' Start the API: cd phonoquest_fastapi_clean && uvicorn app.main:app --host 127.0.0.1 --port 8000')
          : '';
      throw ApiException(0, 'Could not reach the server at $_baseUrl. ${e.message}$hint');
    }
  }

  Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body, {
    bool authorized = false,
  }) async {
    final headers = await _jsonHeaders(authorized: authorized);
    final response = await _execute(
      _http.post(
        _uri(path),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      ApiRequestCoordinator.invalidate(pathContains: path.split('?').first);
    }
    return response;
  }

  Future<http.Response> get(
    String path, {
    bool authorized = false,
    Map<String, String>? queryParameters,
    bool useCache = true,
    Duration? cacheTtl,
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final normalizedPath = path.split('?').first;
    final token = authorized ? await _tokens.readAccessToken() : null;
    final cacheKey = ApiRequestCoordinator.cacheKey(
      'GET',
      uri.toString(),
      authToken: token,
    );

    Future<http.Response> send() async {
      if (!authorized) {
        return _execute(_http.get(uri));
      }
      if (token == null || token.isEmpty) {
        return _execute(_http.get(uri));
      }
      return _execute(
        _http.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    }

    if (!useCache) {
      return send();
    }

    return ApiRequestCoordinator.runGet(
      cacheKey,
      send,
      cacheTtl: cacheTtl ?? ApiRequestCoordinator.defaultCacheTtl,
    );
  }

  Future<http.Response> delete(String path, {bool authorized = false}) async {
    Future<http.Response> send() async {
      if (!authorized) {
        return _execute(_http.delete(_uri(path)));
      }
      final token = await _tokens.readAccessToken();
      if (token == null || token.isEmpty) {
        return _execute(_http.delete(_uri(path)));
      }
      return _execute(
        _http.delete(
          _uri(path),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    }

    final response = await send();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      ApiRequestCoordinator.invalidate(pathContains: path.split('?').first);
    }
    return response;
  }

  Future<http.Response> patchJson(
    String path,
    Map<String, dynamic> body, {
    bool authorized = false,
  }) async {
    final headers = await _jsonHeaders(authorized: authorized);
    final response = await _execute(
      _http.patch(
        _uri(path),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      ApiRequestCoordinator.invalidate(pathContains: path.split('?').first);
    }
    return response;
  }

  static void clearRequestCache() => ApiRequestCoordinator.clearAll();

  static MediaType? mediaTypeFromMime(String? mimeType) {
    final raw = (mimeType ?? '').split(';').first.trim().toLowerCase();
    if (raw.isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return null;
    return MediaType(parts[0], parts[1]);
  }

  /// Multipart upload (e.g. profile photo). [fieldName] is usually `file`.
  Future<http.Response> postMultipart(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    String? mimeType,
    bool authorized = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers['Accept'] = 'application/json';
    if (authorized) {
      final token = await _tokens.readAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: mediaTypeFromMime(mimeType),
      ),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await _execute(http.Response.fromStream(streamed));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      ApiRequestCoordinator.invalidate(pathContains: '/profiles');
      ApiRequestCoordinator.invalidate(pathContains: '/auth/me');
    }
    return response;
  }

  void close() => _http.close();
}
