import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'blend_forest_models.dart';
import 'vowel_learning_models.dart';

class BlendForestRepository {
  BlendForestRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<BlendForestHubPayload> fetchHub() async {
    final http.Response res =
        await _client.get('/blend-forest/hub', authorized: true);

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load Blend Forest.'),
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
      return BlendForestHubPayload.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }

  Future<BlendLessonDetailPayload> fetchLesson(int lessonId) async {
    final http.Response res = await _client.get(
      '/blend-forest/lessons/$lessonId',
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load this lesson.'),
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
      return BlendLessonDetailPayload.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }

  Future<WordBuilderRandomOut> fetchWordBuilderRandom(int lessonId) async {
    final http.Response res = await _client.get(
      '/blend-forest/lessons/$lessonId/word-builder/random',
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load word builder.'),
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
    required List<String> tiles,
  }) async {
    final http.Response res = await _client.postJson(
      '/blend-forest/lessons/$lessonId/word-builder/submit',
      {'word_id': wordId, 'tiles': tiles},
      authorized: true,
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not submit your word.'),
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
