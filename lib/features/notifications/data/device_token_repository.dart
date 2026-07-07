import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  /// `POST /notifications/device-token`
  Future<void> register({required String fcmToken}) async {
    final res = await _client.postJson(
      '/notifications/device-token',
      {
        'fcm_token': fcmToken,
        'platform': _platform,
      },
      authorized: true,
    );
    if (res.statusCode == 200) return;
    final parsed = parseApiError(res.body, fallback: 'Could not register device for notifications.');
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /notifications/device-token/unregister`
  Future<void> unregister({required String fcmToken}) async {
    final res = await _client.postJson(
      '/notifications/device-token/unregister',
      {'fcm_token': fcmToken},
      authorized: true,
    );
    if (res.statusCode == 200) return;
    // Best-effort on logout — do not throw if token already removed.
    if (res.statusCode == 401) return;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic> && decoded['status'] == true) return;
    } catch (_) {}
  }
}
