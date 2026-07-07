import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'teacher_struggling_models.dart';

class TeacherStrugglingRepository {
  TeacherStrugglingRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StrugglingStudentsPayload> fetchStrugglingStudents({
    int? classId,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (classId != null) queryParams['class_id'] = '$classId';

    final response = await _client.get(
      '/teacher/struggling-students',
      authorized: true,
      queryParameters: queryParams,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load struggling students.'),
      );
    }
    try {
      return StrugglingStudentsPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
