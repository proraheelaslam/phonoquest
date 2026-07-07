import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'student_home_models.dart';

class StudentHomeRepository {
  StudentHomeRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentHomePayload> fetchHome({bool useCache = false}) async {
    final response = await _client.get(
      '/student/home',
      authorized: true,
      useCache: useCache,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load student dashboard.'),
      );
    }

    try {
      return StudentHomePayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<StudentNotificationItem>> fetchNotifications({bool useCache = false}) async {
    final response = await _client.get(
      '/student/notifications',
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
