import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'blend_forest_models.dart';
import 'blend_forest_repository.dart';
import 'practice_models.dart';

class PracticeRepository {
  PracticeRepository({
    ApiClient? client,
    BlendForestRepository? hubRepo,
  })  : _client = client ?? ApiClient(),
        _hubRepo = hubRepo ?? BlendForestRepository();

  final ApiClient _client;
  final BlendForestRepository _hubRepo;

  /// Practice Mode uses Blend Forest hub (daily quest, mastery, H-Brothers lessons).
  Future<BlendForestHubPayload> fetchHub() async {
    final hub = await _hubRepo.fetchHub();
    if (hub.dailyQuest != null && hub.dailyQuest!.id > 0) {
      return hub;
    }
    try {
      final quest = await fetchDailyQuest(moduleCode: hub.moduleCode.isNotEmpty ? hub.moduleCode : 'blend_forest');
      return hub.copyWith(dailyQuest: quest);
    } on ApiException {
      return hub;
    }
  }

  Future<DailyQuestModel> fetchDailyQuest({String moduleCode = 'blend_forest'}) async {
    final response = await _client.get(
      '/practice/daily-quest/$moduleCode',
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load daily quest.'),
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid daily quest payload.');
      }
      return DailyQuestModel.fromJson(decoded);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ExerciseSubmitResult> submitExercise({
    required int exerciseId,
    required String selectedCode,
  }) async {
    final response = await _client.postJson(
      '/practice/exercises/$exerciseId/submit',
      {'selected_code': selectedCode},
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not submit your answer.'),
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid submit response.');
      }
      return ExerciseSubmitResult.fromJson(decoded);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
