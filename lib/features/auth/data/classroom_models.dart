import 'dart:convert';

class TeacherClassItem {
  final int id;
  final String name;
  final String? gradeLevel;
  final String? mascotCode;
  final int studentCount;
  final int overallProgress;
  final String? summaryText;

  const TeacherClassItem({
    required this.id,
    required this.name,
    this.gradeLevel,
    this.mascotCode,
    required this.studentCount,
    required this.overallProgress,
    this.summaryText,
  });

  double get progressFraction => (overallProgress.clamp(0, 100)) / 100.0;

  static String gradeLabelFromApi(String? apiValue) {
    switch (apiValue) {
      case 'pre_k':
        return 'Pre-K';
      case 'kindergarten':
        return 'Kindergarten';
      case 'first_grade':
        return '1st Grade';
      case 'second_plus':
        return '2nd Grade +';
      default:
        if (apiValue != null && apiValue.isNotEmpty) {
          return apiValue.replaceAll('_', ' ');
        }
        return 'Class';
    }
  }

  factory TeacherClassItem.fromJson(Map<String, dynamic> json) {
    return TeacherClassItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] as String?) ?? '',
      gradeLevel: json['grade_level'] as String?,
      mascotCode: json['mascot_code'] as String?,
      studentCount: json['student_count'] is int
          ? json['student_count'] as int
          : int.tryParse('${json['student_count']}') ?? 0,
      overallProgress: json['overall_progress'] is int
          ? json['overall_progress'] as int
          : int.tryParse('${json['overall_progress']}') ?? 0,
      summaryText: json['summary_text'] as String?,
    );
  }
}

/// Student in the wizard roster (account may already exist on the server).
class PendingClassStudent {
  final String displayName;
  final String email;
  final String password;
  final int? learnerUserId;

  const PendingClassStudent({
    required this.displayName,
    required this.email,
    required this.password,
    this.learnerUserId,
  });

  PendingClassStudent copyWith({int? learnerUserId}) {
    return PendingClassStudent(
      displayName: displayName,
      email: email,
      password: password,
      learnerUserId: learnerUserId ?? this.learnerUserId,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'display_name': displayName,
      'email': email,
      'reading_level': 'beginner',
    };
    if (learnerUserId != null) {
      map['learner_user_id'] = learnerUserId;
    } else {
      map['password'] = password;
    }
    return map;
  }

  factory PendingClassStudent.fromAccountJson(
    Map<String, dynamic> json, {
    required String password,
  }) {
    return PendingClassStudent(
      displayName: (json['display_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      password: password,
      learnerUserId: json['learner_user_id'] is int
          ? json['learner_user_id'] as int
          : int.tryParse('${json['learner_user_id']}'),
    );
  }
}

class ClassRosterStudent {
  final int? id;
  final String displayName;
  final String? email;

  const ClassRosterStudent({
    this.id,
    required this.displayName,
    this.email,
  });

  bool get isPersisted => id != null;

  factory ClassRosterStudent.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return ClassRosterStudent(
      id: rawId is int ? rawId : int.tryParse('$rawId'),
      displayName: (json['display_name'] as String?) ?? '',
      email: json['email'] as String?,
    );
  }

  ClassRosterStudent copyWith({int? id, String? displayName, String? email}) {
    return ClassRosterStudent(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }
}

class ClassStudentListPayload {
  final int classId;
  final List<ClassRosterStudent> students;

  const ClassStudentListPayload({
    required this.classId,
    required this.students,
  });

  factory ClassStudentListPayload.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'];
    final list = rawStudents is List
        ? rawStudents
            .whereType<Map<String, dynamic>>()
            .map(ClassRosterStudent.fromJson)
            .toList()
        : <ClassRosterStudent>[];
    return ClassStudentListPayload(
      classId: json['class_id'] is int
          ? json['class_id'] as int
          : int.tryParse('${json['class_id']}') ?? 0,
      students: list,
    );
  }
}

class StudentDirectoryItem {
  final int id;
  final String displayName;
  final String email;
  final String? readingLevel;

  const StudentDirectoryItem({
    required this.id,
    required this.displayName,
    required this.email,
    this.readingLevel,
  });

  factory StudentDirectoryItem.fromJson(Map<String, dynamic> json) {
    return StudentDirectoryItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      displayName: (json['display_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      readingLevel: json['reading_level'] as String?,
    );
  }
}

T _parseData<T>(String body, T Function(Map<String, dynamic>) fromData) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw FormatException('Invalid response payload.');
  }
  return fromData(data);
}

List<TeacherClassItem> parseClassListBody(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! List) {
    throw FormatException('Invalid class list payload.');
  }
  return data
      .whereType<Map<String, dynamic>>()
      .map(TeacherClassItem.fromJson)
      .toList();
}

TeacherClassItem parseClassBody(String body) =>
    _parseData(body, TeacherClassItem.fromJson);

ClassStudentListPayload parseClassStudentsBody(String body) =>
    _parseData(body, ClassStudentListPayload.fromJson);

List<StudentDirectoryItem> parseStudentDirectoryBody(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! List) {
    throw FormatException('Invalid student directory payload.');
  }
  return data
      .whereType<Map<String, dynamic>>()
      .map(StudentDirectoryItem.fromJson)
      .toList();
}
