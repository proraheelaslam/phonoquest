import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'teacher_reports_models.dart';

class TeacherReportsRepository {
  TeacherReportsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TeacherReportsPayload> fetchReports({
    int? classId,
    String? query,
    int studentLimit = 20,
  }) async {
    final queryParams = <String, String>{'student_limit': '$studentLimit'};
    if (classId != null) queryParams['class_id'] = '$classId';
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }

    final response = await _client.get(
      '/teacher/reports',
      authorized: true,
      queryParameters: queryParams,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load reports.'),
      );
    }

    try {
      return TeacherReportsPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
