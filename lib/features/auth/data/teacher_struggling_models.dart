import 'dart:convert';

class StrugglingStudentsPayload {
  final int strugglingCount;
  final List<StrugglingStudentItem> students;

  const StrugglingStudentsPayload({
    required this.strugglingCount,
    required this.students,
  });

  factory StrugglingStudentsPayload.fromJson(Map<String, dynamic> json) {
    final studentsJson = json['students'];
    return StrugglingStudentsPayload(
      strugglingCount: _asInt(json['struggling_count']),
      students: studentsJson is List
          ? studentsJson.whereType<Map<String, dynamic>>().map(StrugglingStudentItem.fromJson).toList()
          : const [],
    );
  }

  static StrugglingStudentsPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid struggling students payload.');
    }
    return StrugglingStudentsPayload.fromJson(data);
  }
}

class StrugglingStudentItem {
  final int studentId;
  final String displayName;
  final String initials;
  final String gradeLabel;
  final int classId;
  final String? className;
  final int masteryPercent;
  final String alertKey;
  final String tagLabel;
  final String message;
  final String moduleCode;
  final String lessonPlanRoute;
  final String helpMessageSuggestion;

  const StrugglingStudentItem({
    required this.studentId,
    required this.displayName,
    required this.initials,
    required this.gradeLabel,
    required this.classId,
    this.className,
    required this.masteryPercent,
    required this.alertKey,
    required this.tagLabel,
    required this.message,
    required this.moduleCode,
    required this.lessonPlanRoute,
    required this.helpMessageSuggestion,
  });

  factory StrugglingStudentItem.fromJson(Map<String, dynamic> json) {
    return StrugglingStudentItem(
      studentId: _asInt(json['student_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      initials: (json['initials'] as String?) ?? '?',
      gradeLabel: (json['grade_label'] as String?) ?? 'Grade',
      classId: _asInt(json['class_id']),
      className: json['class_name'] as String?,
      masteryPercent: _asInt(json['mastery_percent']),
      alertKey: (json['alert_key'] as String?) ?? 'area_of_focus',
      tagLabel: (json['tag_label'] as String?) ?? 'AREA OF FOCUS',
      message: (json['message'] as String?) ?? '',
      moduleCode: (json['module_code'] as String?) ?? 'alphabet_lounge',
      lessonPlanRoute: (json['lesson_plan_route'] as String?) ?? 'alphabet',
      helpMessageSuggestion: (json['help_message_suggestion'] as String?) ?? '',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
