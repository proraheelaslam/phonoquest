import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'student_home_models.dart';

class StudentLearningAdventuresRepository {
  StudentLearningAdventuresRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<LearningAdventuresPayload> fetchAdventures() async {
    final response = await _client.get(
      '/student/learning-adventures',
      authorized: true,
      useCache: false,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load learning adventures.'),
      );
    }
    try {
      return LearningAdventuresPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
