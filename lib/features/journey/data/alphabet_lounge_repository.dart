import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_request_coordinator.dart';
import 'alphabet_lounge_models.dart';

class AlphabetLoungeRepository {
  AlphabetLoungeRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AlphabetLoungePayload> fetchLounge({bool forceRefresh = false}) async {
    if (forceRefresh) {
      ApiRequestCoordinator.invalidate(pathContains: '/alphabet/lounge');
    }
    final http.Response res = await _client.get(
      '/alphabet/lounge',
      authorized: true,
      useCache: !forceRefresh,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load Alphabet Lounge.'),
      );
    }

    late final Map<String, dynamic> root;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      root = decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }

    if (root['status'] != true) {
      final msg = root['message'];
      throw ApiException(
        res.statusCode,
        msg is String && msg.trim().isNotEmpty
            ? msg.trim()
            : 'Could not load Alphabet Lounge.',
      );
    }

    final data = root['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(res.statusCode, 'Invalid lounge payload.');
    }

    return AlphabetLoungePayload.fromJson(data);
  }

  Future<LetterDetailPayload> fetchLetterDetail(int letterId) async {
    final http.Response res =
        await _client.get('/alphabet/letters/$letterId', authorized: true);

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load this letter.'),
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      final inner = decoded['data'];
      if (inner is Map<String, dynamic>) {
        return LetterDetailPayload.fromJson(inner);
      }
      return LetterDetailPayload.fromJson(decoded);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }

  Future<FindSoundActivityPayload> fetchFindSoundActivity(int letterId) async {
    final http.Response res = await _client.get(
      '/alphabet/letters/$letterId/activity/find-sound',
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load this activity.'),
      );
    }

    late final Map<String, dynamic> root;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      root = decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }

    final Map<String, dynamic> payloadMap;
    if (root['status'] == true && root['data'] is Map<String, dynamic>) {
      payloadMap = root['data'] as Map<String, dynamic>;
    } else {
      payloadMap = root;
    }

    try {
      return FindSoundActivityPayload.fromJson(payloadMap);
    } catch (_) {
      throw ApiException(res.statusCode, 'Invalid activity payload.');
    }
  }

  Future<FindSoundSubmitData> submitFindSoundSelection(
    int letterId,
    int selectedWordId,
  ) async {
    final http.Response res = await _client.postJson(
      '/alphabet/letters/$letterId/activity/find-word/submit',
      {'selected_word_id': selectedWordId},
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not submit your answer.'),
      );
    }

    // Letter completion updates grid status — stale lounge cache showed no checkmark.
    ApiRequestCoordinator.invalidate(pathContains: '/alphabet');

    late final Map<String, dynamic> root;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      root = decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }

    if (root['status'] != true) {
      final msg = root['message'];
      throw ApiException(
        res.statusCode,
        msg is String && msg.trim().isNotEmpty
            ? msg.trim()
            : 'Could not submit your answer.',
      );
    }

    final data = root['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(res.statusCode, 'Invalid submit payload.');
    }

    try {
      return FindSoundSubmitData.fromJson(data);
    } catch (_) {
      throw ApiException(res.statusCode, 'Invalid submit payload.');
    }
  }

  Future<MasteredLettersPayload> fetchMasteredLetters({bool forceRefresh = false}) async {
    if (forceRefresh) {
      ApiRequestCoordinator.invalidate(pathContains: '/alphabet/progress/mastered');
    }
    final http.Response res = await _client.get(
      '/alphabet/progress/mastered',
      authorized: true,
      useCache: !forceRefresh,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load mastered letters.'),
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      final inner = decoded['data'];
      if (inner is Map<String, dynamic>) {
        return MasteredLettersPayload.fromJson(inner);
      }
      return MasteredLettersPayload.fromJson(decoded);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid mastered letters payload.');
    }
  }
}
