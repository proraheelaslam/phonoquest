import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'classroom_models.dart';

class ClassroomRepository {
  ClassroomRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// FastAPI registers collection routes as `/classes/` (trailing slash).
  static const String _classesPath = '/classes/';

  Future<TeacherClassItem> createClassWithStudents({
    required String name,
    required String gradeLevel,
    required String mascotCode,
    required List<PendingClassStudent> students,
  }) async {
    // Use POST /classes/ (same as create class) — avoids 405 on hosts that block /with-students.
    final res = await _client.postJson(
      _classesPath,
      {
        'name': name.trim(),
        'grade_level': gradeLevel,
        'mascot_code': mascotCode,
        'students': students.map((s) => s.toJson()).toList(),
      },
      authorized: true,
    );

    if (res.statusCode == 201) {
      try {
        return parseClassBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not create class.'),
    );
  }

  Future<TeacherClassItem> createClass({
    required String name,
    required String gradeLevel,
    required String mascotCode,
  }) async {
    final res = await _client.postJson(
      _classesPath,
      {
        'name': name.trim(),
        'grade_level': gradeLevel,
        'mascot_code': mascotCode,
      },
      authorized: true,
    );

    if (res.statusCode == 201) {
      try {
        return parseClassBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not create class.'),
    );
  }

  Future<TeacherClassItem> fetchClass(int classId) async {
    final res = await _client.get('/classes/$classId', authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseClassBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load class details.'),
    );
  }

  Future<List<TeacherClassItem>> listClasses() async {
    final res = await _client.get(_classesPath, authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseClassListBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load classes.'),
    );
  }

  Future<ClassStudentListPayload> listStudents(int classId) async {
    final res = await _client.get('/classes/$classId/students', authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseClassStudentsBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load students.'),
    );
  }

  /// Creates student user on server (wizard Add button — before class exists).
  Future<PendingClassStudent> createStudentAccount(PendingClassStudent draft) async {
    final res = await _client.postJson(
      '/classes/students/accounts',
      {
        'display_name': draft.displayName,
        'email': draft.email,
        'password': draft.password,
        'reading_level': 'beginner',
      },
      authorized: true,
    );

    if (res.statusCode == 201) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException('Invalid response from server.');
        }
        final data = decoded['data'];
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid student account payload.');
        }
        return PendingClassStudent.fromAccountJson(data, password: draft.password);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not create student account.'),
    );
  }

  Future<ClassStudentListPayload> registerStudentInClass({
    required int classId,
    required PendingClassStudent student,
  }) async {
    final res = await _client.postJson(
      '/classes/$classId/students/register',
      student.toJson(),
      authorized: true,
    );

    if (res.statusCode == 201) {
      try {
        return parseClassStudentsBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not add student.'),
    );
  }

  Future<ClassStudentListPayload> addStudents({
    required int classId,
    required List<String> displayNames,
    Map<String, int>? learnerUserIdsByName,
  }) async {
    final students = displayNames
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .map((n) {
          final entry = <String, dynamic>{'display_name': n};
          final learnerId = learnerUserIdsByName?[n];
          if (learnerId != null) {
            entry['learner_user_id'] = learnerId;
          }
          return entry;
        })
        .toList();

    if (students.isEmpty) {
      throw ApiException(400, 'Add at least one student name.');
    }

    final res = await _client.postJson(
      '/classes/$classId/students',
      {'students': students},
      authorized: true,
    );

    if (res.statusCode == 201) {
      try {
        return parseClassStudentsBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not add students.'),
    );
  }

  Future<List<ClassRosterStudent>> removeStudent({
    required int classId,
    required int studentId,
  }) async {
    final res = await _client.delete(
      '/classes/$classId/students/$studentId',
      authorized: true,
    );

    if (res.statusCode == 200) {
      try {
        return parseClassStudentsBody(res.body).students;
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not remove student.'),
    );
  }

  Future<List<StudentDirectoryItem>> searchStudentDirectory({
    required String query,
    int? classId,
    int limit = 20,
  }) async {
    final q = Uri.encodeQueryComponent(query.trim());
    final classPart = classId != null ? '&class_id=$classId' : '';
    final res = await _client.get(
      '/classes/student-directory?query=$q&limit=$limit$classPart',
      authorized: true,
    );
    if (res.statusCode == 200) {
      try {
        return parseStudentDirectoryBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load student directory.'),
    );
  }
}
