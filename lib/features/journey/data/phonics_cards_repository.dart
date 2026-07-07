import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'phonics_cards_models.dart';

class PhonicsCardsRepository {
  PhonicsCardsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<PhonicsCardPayload> fetchCards() async {
    final http.Response res = await _client.get(
      '/phonics/cards',
      authorized: true,
      cacheTtl: const Duration(minutes: 10),
    );

    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        parseApiErrorBody(res.body, fallback: 'Could not load phonics cards.'),
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
      return PhonicsCardPayload.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Invalid response from server.');
    }
  }
}
