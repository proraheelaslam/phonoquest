import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_request_coordinator.dart';
import 'parent_messages_models.dart';

class ParentMessagesRepository {
  ParentMessagesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static int? _cachedUnreadCount;
  static DateTime? _cachedUnreadAt;
  static const Duration _unreadCacheTtl = Duration(minutes: 5);

  static void invalidateUnreadCountCache() {
    _cachedUnreadCount = null;
    _cachedUnreadAt = null;
    ApiRequestCoordinator.invalidate(pathContains: '/messages/parent/unread-count');
  }

  Future<List<ParentInboxMessage>> fetchInbox() async {
    final response = await _client.get('/messages/parent/inbox', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load messages.'),
      );
    }
    try {
      return ParentInboxMessage.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<int> fetchUnreadCount() async {
    final cachedAt = _cachedUnreadAt;
    if (_cachedUnreadCount != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _unreadCacheTtl) {
      return _cachedUnreadCount!;
    }

    final response = await _client.get(
      '/messages/parent/unread-count',
      authorized: true,
      cacheTtl: _unreadCacheTtl,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load unread count.'),
      );
    }
    final decoded = jsonDecode(response.body);
    var count = 0;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        count = _asInt(data['unread_count']);
      }
    }
    _cachedUnreadCount = count;
    _cachedUnreadAt = DateTime.now();
    return count;
  }

  Future<void> markAllRead() async {
    final response = await _client.postJson('/messages/parent/mark-read', {}, authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not update messages.'),
      );
    }
    invalidateUnreadCountCache();
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
