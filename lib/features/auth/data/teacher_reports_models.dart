import 'dart:convert';

class TeacherReportsPayload {
  final String subtitle;
  final String weeklyChartTitle;
  final ReportStats stats;
  final List<WeeklyReportBar> weeklyActivity;
  final List<ReportActionCard> actionCards;
  final List<StudentPerformanceRow> students;
  final int totalStudents;
  final int strugglingCount;

  const TeacherReportsPayload({
    required this.subtitle,
    required this.weeklyChartTitle,
    required this.stats,
    required this.weeklyActivity,
    required this.actionCards,
    required this.students,
    required this.totalStudents,
    required this.strugglingCount,
  });

  factory TeacherReportsPayload.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'];
    final weekly = json['weekly_activity'];
    final cards = json['action_cards'];
    final studentsJson = json['students'];

    return TeacherReportsPayload(
      subtitle: (json['subtitle'] as String?) ?? '',
      weeklyChartTitle: (json['weekly_chart_title'] as String?) ?? 'Weekly Activity',
      stats: statsJson is Map<String, dynamic>
          ? ReportStats.fromJson(statsJson)
          : const ReportStats(
              averageAccuracyPct: 0,
              activeStudents: 0,
              totalStudents: 0,
              classAccuracyPct: 0,
            ),
      weeklyActivity: weekly is List
          ? weekly.whereType<Map<String, dynamic>>().map(WeeklyReportBar.fromJson).toList()
          : const [],
      actionCards: cards is List
          ? cards.whereType<Map<String, dynamic>>().map(ReportActionCard.fromJson).toList()
          : const [],
      students: studentsJson is List
          ? studentsJson.whereType<Map<String, dynamic>>().map(StudentPerformanceRow.fromJson).toList()
          : const [],
      totalStudents: _asInt(json['total_students']),
      strugglingCount: _asInt(json['struggling_count']),
    );
  }

  static TeacherReportsPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid teacher reports payload.');
    }
    return TeacherReportsPayload.fromJson(data);
  }
}

class ReportStats {
  final int averageAccuracyPct;
  final double? averageAccuracyDeltaPct;
  final int activeStudents;
  final int totalStudents;
  final int classAccuracyPct;
  final double? classAccuracyDeltaPct;

  const ReportStats({
    required this.averageAccuracyPct,
    this.averageAccuracyDeltaPct,
    required this.activeStudents,
    required this.totalStudents,
    required this.classAccuracyPct,
    this.classAccuracyDeltaPct,
  });

  factory ReportStats.fromJson(Map<String, dynamic> json) {
    return ReportStats(
      averageAccuracyPct: _asInt(json['average_accuracy_pct']),
      averageAccuracyDeltaPct: _asDouble(json['average_accuracy_delta_pct']),
      activeStudents: _asInt(json['active_students']),
      totalStudents: _asInt(json['total_students']),
      classAccuracyPct: _asInt(json['class_accuracy_pct']),
      classAccuracyDeltaPct: _asDouble(json['class_accuracy_delta_pct']),
    );
  }

  double get activeRatio =>
      totalStudents > 0 ? activeStudents / totalStudents : 0.0;
}

class WeeklyReportBar {
  final String dayLabel;
  final int completedCount;
  final int assignedCount;
  final double completedRatio;
  final double assignedRatio;

  const WeeklyReportBar({
    required this.dayLabel,
    required this.completedCount,
    required this.assignedCount,
    required this.completedRatio,
    required this.assignedRatio,
  });

  factory WeeklyReportBar.fromJson(Map<String, dynamic> json) {
    return WeeklyReportBar(
      dayLabel: (json['day_label'] as String?) ?? '',
      completedCount: _asInt(json['completed_count']),
      assignedCount: _asInt(json['assigned_count']),
      completedRatio: _asDouble(json['completed_ratio']) ?? 0,
      assignedRatio: _asDouble(json['assigned_ratio']) ?? 0,
    );
  }
}

class ReportActionCard {
  final String key;
  final String title;
  final String subtitle;

  const ReportActionCard({
    required this.key,
    required this.title,
    required this.subtitle,
  });

  factory ReportActionCard.fromJson(Map<String, dynamic> json) {
    return ReportActionCard(
      key: (json['key'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
    );
  }
}

class StudentPerformanceRow {
  final int studentId;
  final String displayName;
  final String initials;
  final int masteryPercent;
  final String lastActiveLabel;

  const StudentPerformanceRow({
    required this.studentId,
    required this.displayName,
    required this.initials,
    required this.masteryPercent,
    required this.lastActiveLabel,
  });

  factory StudentPerformanceRow.fromJson(Map<String, dynamic> json) {
    return StudentPerformanceRow(
      studentId: _asInt(json['student_id']),
      displayName: (json['display_name'] as String?) ?? '',
      initials: (json['initials'] as String?) ?? '?',
      masteryPercent: _asInt(json['mastery_percent']),
      lastActiveLabel: (json['last_active_label'] as String?) ?? '',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse('$value');
}

String formatDeltaLabel(double? delta) {
  if (delta == null) return '';
  final sign = delta >= 0 ? '+' : '';
  return '$sign${delta.toStringAsFixed(1)}% from last week';
}
