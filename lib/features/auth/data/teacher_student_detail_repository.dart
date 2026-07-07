import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'teacher_student_detail_models.dart';

class TeacherStudentDetailRepository {
  TeacherStudentDetailRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TeacherStudentDetail> fetchStudentDetail(int studentId) async {
    final response = await _client.get(
      '/teacher/students/$studentId/detail',
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load student detail.'),
      );
    }
    try {
      return TeacherStudentDetail.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  String reportPdfPath(int studentId) => '/teacher/students/$studentId/report.pdf';
}
