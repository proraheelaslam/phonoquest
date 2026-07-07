import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../domain/assignment_creation_draft.dart';
import 'teacher_assignment_models.dart';

class TeacherAssignmentRepository {
  TeacherAssignmentRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TeacherModulesCatalog> fetchModulesCatalog() async {
    final response = await _client.get('/teacher/modules', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load modules.'),
      );
    }
    try {
      return TeacherModulesCatalog.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<AssignmentRecipientsPayload> fetchRecipients({required String moduleCode}) async {
    final response = await _client.get(
      '/teacher/assignments/recipients',
      authorized: true,
      queryParameters: {'module_code': moduleCode},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load recipients.'),
      );
    }
    try {
      return AssignmentRecipientsPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<AssignmentDetail> createAssignment(AssignmentCreationDraft draft) async {
    final body = <String, dynamic>{
      'module_code': draft.moduleCode,
      'recipient_mode': draft.recipientMode,
    };
    if (draft.classId != null) {
      body['class_id'] = draft.classId;
    }
    if (draft.selectedStudentIds.isNotEmpty) {
      body['student_ids'] = draft.selectedStudentIds;
    }
    if (draft.scheduleDueAt != null) {
      body['schedule_due_at'] = draft.scheduleDueAt!.toUtc().toIso8601String();
    }
    if (draft.teacherNote != null && draft.teacherNote!.trim().isNotEmpty) {
      body['teacher_note'] = draft.teacherNote!.trim();
    }

    final response = await _client.postJson('/teacher/assignments', body, authorized: true);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not create assignment.'),
      );
    }
    try {
      return AssignmentDetail.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<AssignmentDetail> fetchAssignmentDetail(int assignmentId) async {
    final response = await _client.get(
      '/teacher/assignments/$assignmentId',
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load assignment.'),
      );
    }
    try {
      return AssignmentDetail.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<ReviewQueueItem>> fetchReviewQueue({int limit = 50}) async {
    final response = await _client.get(
      '/teacher/assignments/review-queue',
      authorized: true,
      queryParameters: {'limit': '$limit'},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load review queue.'),
      );
    }
    try {
      return ReviewQueueItem.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<AssignmentAnalytics> fetchAssignmentAnalytics(int assignmentId) async {
    final response = await _client.get(
      '/teacher/assignments/$assignmentId/analytics',
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load analytics.'),
      );
    }
    try {
      return AssignmentAnalytics.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<AssignmentDetail>> fetchAssignments({int limit = 50}) async {
    final response = await _client.get(
      '/teacher/assignments',
      authorized: true,
      queryParameters: {'limit': '$limit'},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load assignments.'),
      );
    }
    try {
      return AssignmentDetail.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<AssignmentDetail> cancelAssignment(int assignmentId) async {
    final response = await _client.delete(
      '/teacher/assignments/$assignmentId',
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not cancel assignment.'),
      );
    }
    try {
      return AssignmentDetail.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
