import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../../dashboard/data/student_home_models.dart';
import 'parent_resources_models.dart';
import 'celebration_report_models.dart';
import 'teacher_dashboard_models.dart';

class TeacherDashboardRepository {
  TeacherDashboardRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TeacherDashboardPayload> fetchDashboard({
    int? classId,
    int studentLimit = 5,
    int activityLimit = 10,
  }) async {
    final query = <String, String>{
      'student_limit': '$studentLimit',
      'activity_limit': '$activityLimit',
    };
    if (classId != null) {
      query['class_id'] = '$classId';
    }

    final response = await _client.get(
      '/dashboard/teacher',
      authorized: true,
      queryParameters: query,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load teacher dashboard.'),
      );
    }

    try {
      return TeacherDashboardPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<CelebrationReportPayload> fetchCelebrationReport({
    int? classId,
    int studentLimit = 8,
    int highlightLimit = 12,
  }) async {
    final query = <String, String>{
      'student_limit': '$studentLimit',
      'highlight_limit': '$highlightLimit',
    };
    if (classId != null) {
      query['class_id'] = '$classId';
    }

    final response = await _client.get(
      '/dashboard/teacher/celebration-report',
      authorized: true,
      queryParameters: query,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load celebration report.'),
      );
    }

    try {
      return CelebrationReportPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ParentResourcesPayload> fetchResources({
    String tab = 'all',
    String? query,
  }) async {
    final q = query?.trim();
    final response = await _client.get(
      '/teacher/resources',
      authorized: true,
      queryParameters: {
        'tab': tab,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load resources.'),
      );
    }

    try {
      return ParentResourcesPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<StudentNotificationItem>> fetchNotifications({bool useCache = false}) async {
    final response = await _client.get(
      '/teacher/notifications',
      authorized: true,
      useCache: useCache,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load notifications.'),
      );
    }
    try {
      return StudentNotificationItem.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
