import 'dart:convert';

class ParsedApiError {
  final String message;
  final String? code;

  const ParsedApiError({required this.message, this.code});
}

/// Shared parsing for FastAPI JSON errors (`message`, `detail`, validation list).
ParsedApiError parseApiError(String body, {required String fallback}) {
  if (body.isEmpty) return ParsedApiError(message: fallback);
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final msg = decoded['message'];
      if (msg is String && msg.trim().isNotEmpty) {
        return ParsedApiError(message: msg.trim());
      }
      final detail = decoded['detail'];
      if (detail is Map) {
        final detailMsg = detail['message'];
        final detailCode = detail['code'];
        if (detailMsg is String && detailMsg.trim().isNotEmpty) {
          return ParsedApiError(
            message: detailMsg.trim(),
            code: detailCode is String ? detailCode : null,
          );
        }
      }
      if (detail is String && detail.trim().isNotEmpty) {
        return ParsedApiError(message: detail.trim());
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return ParsedApiError(message: (first['msg'] as String).trim());
        }
      }
    }
  } catch (_) {
    /* ignore */
  }
  return ParsedApiError(message: fallback);
}

String parseApiErrorBody(String body, {required String fallback}) {
  return parseApiError(body, fallback: fallback).message;
}
