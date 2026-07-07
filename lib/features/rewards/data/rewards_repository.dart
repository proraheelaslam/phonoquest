import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'rewards_models.dart';

class RewardsRepository {
  RewardsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RewardsHubPayload> fetchHub() async {
    final response = await _client.get('/student/rewards', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load rewards.'),
      );
    }
    try {
      return RewardsHubPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ClaimRewardResult> claimReward(String rewardCode) async {
    final response = await _client.postJson(
      '/student/rewards/$rewardCode/claim',
      const {},
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not claim reward.'),
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid claim response.');
      }
      return ClaimRewardResult.fromJson(decoded);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
