import 'dart:convert';

import 'package:phonoquest_signup_flow/core/network/api_client.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'smart_chart_models.dart';

class SmartChartRepository {
  SmartChartRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<SmartChartPayload> fetchSmartChart() async {
    final response = await _client.get('/smart-chart', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        'Could not load smart chart. Please sign in and try again.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(response.statusCode, 'Invalid response from server.');
    }

    final data = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;
    return SmartChartPayload.fromJson(data);
  }
}
