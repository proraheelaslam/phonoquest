import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'vowel_learning_models.dart';

class VowelLearningRepository {
  VowelLearningRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<VowelHubPayload> fetchHub() async {
    final http.Response res = await _client.get('/vowel-learning/hub', authorized: true);

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load Vowel Learning hub.'),
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return VowelHubPayload.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }

  Future<WordBuilderRandomOut> fetchWordBuilderRandom(int lessonId) async {
    final http.Response res = await _client.get(
      '/vowel-learning/lessons/$lessonId/word-builder/random',
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load word-builder round.'),
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return WordBuilderRandomOut.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }

  Future<WordBuilderSubmitResultOut> submitWordBuilder({
    required int lessonId,
    required int wordId,
    String? vowelLetter,
    List<String>? tiles,
  }) async {
    final body = <String, dynamic>{'word_id': wordId};
    if (vowelLetter != null) {
      body['vowel_letter'] = vowelLetter;
    }
    if (tiles != null) {
      body['tiles'] = tiles;
    }

    final http.Response res = await _client.postJson(
      '/vowel-learning/lessons/$lessonId/word-builder/submit',
      body,
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not submit word-builder attempt.'),
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return WordBuilderSubmitResultOut.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }
}
