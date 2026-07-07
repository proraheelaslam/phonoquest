import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'student_progress_models.dart';

class StudentProgressRepository {
  StudentProgressRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentProgressPayload> fetchProgress() async {
    final response = await _client.get('/student/progress', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load progress.'),
      );
    }

    try {
      return StudentProgressPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<RecentActivity>> fetchAllActivities() async {
    final response =
        await _client.get('/student/progress/activities', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load activities.'),
      );
    }

    try {
      return RecentActivity.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
