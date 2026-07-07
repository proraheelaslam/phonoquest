import 'dart:convert';

class TeacherStudentDetail {
  final int studentId;
  final String displayName;
  final String initials;
  final String gradeLabel;
  final int classId;
  final String className;
  final String subtitle;
  final int masteryPercent;
  final String growthLabel;
  final bool growthPositive;
  final String chartTitle;
  final List<WeeklyFluencyPoint> weeklyFluency;
  final String currentQuestTitle;
  final String currentQuestSubtitle;
  final int currentQuestCompletionPct;
  final List<StudentFocusArea> focusAreas;
  final List<String> masteryItems;
  final int masteryTotalCount;
  final String messageParentSuggestion;
  final String reportPdfFilename;
  final bool parentLinked;
  final int linkedParentCount;
  final String? studentQuestCode;
  final String? parentLinkHint;

  const TeacherStudentDetail({
    required this.studentId,
    required this.displayName,
    required this.initials,
    required this.gradeLabel,
    required this.classId,
    required this.className,
    required this.subtitle,
    required this.masteryPercent,
    required this.growthLabel,
    required this.growthPositive,
    required this.chartTitle,
    required this.weeklyFluency,
    required this.currentQuestTitle,
    required this.currentQuestSubtitle,
    required this.currentQuestCompletionPct,
    required this.focusAreas,
    required this.masteryItems,
    required this.masteryTotalCount,
    required this.messageParentSuggestion,
    required this.reportPdfFilename,
    this.parentLinked = false,
    this.linkedParentCount = 0,
    this.studentQuestCode,
    this.parentLinkHint,
  });

  factory TeacherStudentDetail.fromJson(Map<String, dynamic> json) {
    final weekly = json['weekly_fluency'];
    final focus = json['focus_areas'];
    final mastery = json['mastery_items'];

    return TeacherStudentDetail(
      studentId: _asInt(json['student_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      initials: (json['initials'] as String?) ?? '?',
      gradeLabel: (json['grade_label'] as String?) ?? 'Grade',
      classId: _asInt(json['class_id']),
      className: (json['class_name'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      masteryPercent: _asInt(json['mastery_percent']),
      growthLabel: (json['growth_label'] as String?) ?? '',
      growthPositive: json['growth_positive'] == true,
      chartTitle: (json['chart_title'] as String?) ?? 'Reading Fluency',
      weeklyFluency: weekly is List
          ? weekly.whereType<Map<String, dynamic>>().map(WeeklyFluencyPoint.fromJson).toList()
          : const [],
      currentQuestTitle: (json['current_quest_title'] as String?) ?? 'Current Quest',
      currentQuestSubtitle: (json['current_quest_subtitle'] as String?) ?? '',
      currentQuestCompletionPct: _asInt(json['current_quest_completion_pct']),
      focusAreas: focus is List
          ? focus.whereType<Map<String, dynamic>>().map(StudentFocusArea.fromJson).toList()
          : const [],
      masteryItems: mastery is List ? mastery.whereType<String>().toList() : const [],
      masteryTotalCount: _asInt(json['mastery_total_count']),
      messageParentSuggestion: (json['message_parent_suggestion'] as String?) ?? '',
      reportPdfFilename: (json['report_pdf_filename'] as String?) ?? 'student-report.pdf',
      parentLinked: json['parent_linked'] == true,
      linkedParentCount: _asInt(json['linked_parent_count']),
      studentQuestCode: json['student_quest_code'] as String?,
      parentLinkHint: json['parent_link_hint'] as String?,
    );
  }

  static TeacherStudentDetail fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid student detail payload.');
    }
    return TeacherStudentDetail.fromJson(data);
  }
}

class WeeklyFluencyPoint {
  final String dayLabel;
  final int activityCount;
  final double ratio;

  const WeeklyFluencyPoint({
    required this.dayLabel,
    required this.activityCount,
    required this.ratio,
  });

  factory WeeklyFluencyPoint.fromJson(Map<String, dynamic> json) {
    return WeeklyFluencyPoint(
      dayLabel: (json['day_label'] as String?) ?? '',
      activityCount: _asInt(json['activity_count']),
      ratio: _asDouble(json['ratio']),
    );
  }
}

class StudentFocusArea {
  final String title;
  final String tag;
  final String tagKey;
  final String description;

  const StudentFocusArea({
    required this.title,
    required this.tag,
    required this.tagKey,
    required this.description,
  });

  factory StudentFocusArea.fromJson(Map<String, dynamic> json) {
    return StudentFocusArea(
      title: (json['title'] as String?) ?? '',
      tag: (json['tag'] as String?) ?? '',
      tagKey: (json['tag_key'] as String?) ?? 'needs_practice',
      description: (json['description'] as String?) ?? '',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
