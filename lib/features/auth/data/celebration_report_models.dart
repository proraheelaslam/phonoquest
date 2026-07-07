import 'dart:convert';

import 'teacher_reports_models.dart';

class CelebrationReportPayload {
  final String title;
  final String monthLabel;
  final String? className;
  final String summary;
  final CelebrationStats stats;
  final List<CelebrationPerformer> topPerformers;
  final List<CelebrationHighlight> highlights;
  final List<WeeklyReportBar> weeklyActivity;
  final String weeklyChartTitle;

  const CelebrationReportPayload({
    required this.title,
    required this.monthLabel,
    required this.className,
    required this.summary,
    required this.stats,
    required this.topPerformers,
    required this.highlights,
    required this.weeklyActivity,
    required this.weeklyChartTitle,
  });

  factory CelebrationReportPayload.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'];
    final performers = json['top_performers'];
    final highlightsJson = json['highlights'];
    final weekly = json['weekly_activity'];

    return CelebrationReportPayload(
      title: (json['title'] as String?) ?? 'Celebration Report',
      monthLabel: (json['month_label'] as String?) ?? '',
      className: json['class_name'] as String?,
      summary: (json['summary'] as String?) ?? '',
      stats: statsJson is Map<String, dynamic>
          ? CelebrationStats.fromJson(statsJson)
          : const CelebrationStats(
              monthActivities: 0,
              completedSkills: 0,
              activeStudents: 0,
              totalStudents: 0,
              avgMasteryPct: 0,
            ),
      topPerformers: performers is List
          ? performers
              .whereType<Map<String, dynamic>>()
              .map(CelebrationPerformer.fromJson)
              .toList()
          : const [],
      highlights: highlightsJson is List
          ? highlightsJson
              .whereType<Map<String, dynamic>>()
              .map(CelebrationHighlight.fromJson)
              .toList()
          : const [],
      weeklyActivity: weekly is List
          ? weekly.whereType<Map<String, dynamic>>().map(WeeklyReportBar.fromJson).toList()
          : const [],
      weeklyChartTitle:
          (json['weekly_chart_title'] as String?) ?? 'Weekly Activity',
    );
  }

  static CelebrationReportPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid celebration report payload.');
    }
    return CelebrationReportPayload.fromJson(data);
  }
}

class CelebrationStats {
  final int monthActivities;
  final int completedSkills;
  final int activeStudents;
  final int totalStudents;
  final int avgMasteryPct;

  const CelebrationStats({
    required this.monthActivities,
    required this.completedSkills,
    required this.activeStudents,
    required this.totalStudents,
    required this.avgMasteryPct,
  });

  factory CelebrationStats.fromJson(Map<String, dynamic> json) {
    return CelebrationStats(
      monthActivities: _asInt(json['month_activities']),
      completedSkills: _asInt(json['completed_skills']),
      activeStudents: _asInt(json['active_students']),
      totalStudents: _asInt(json['total_students']),
      avgMasteryPct: _asInt(json['avg_mastery_pct']),
    );
  }
}

class CelebrationPerformer {
  final int studentId;
  final String displayName;
  final String initials;
  final int masteryPercent;
  final String badgeLabel;
  final String? note;
  final String? className;

  const CelebrationPerformer({
    required this.studentId,
    required this.displayName,
    required this.initials,
    required this.masteryPercent,
    required this.badgeLabel,
    required this.note,
    required this.className,
  });

  factory CelebrationPerformer.fromJson(Map<String, dynamic> json) {
    return CelebrationPerformer(
      studentId: _asInt(json['student_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      initials: (json['initials'] as String?) ?? '?',
      masteryPercent: _asInt(json['mastery_percent']),
      badgeLabel: (json['badge_label'] as String?) ?? 'Explorer',
      note: json['note'] as String?,
      className: json['class_name'] as String?,
    );
  }
}

class CelebrationHighlight {
  final String studentName;
  final String activityName;
  final String timeLabel;
  final String badgeText;

  const CelebrationHighlight({
    required this.studentName,
    required this.activityName,
    required this.timeLabel,
    required this.badgeText,
  });

  factory CelebrationHighlight.fromJson(Map<String, dynamic> json) {
    return CelebrationHighlight(
      studentName: (json['student_name'] as String?) ?? 'Student',
      activityName: (json['activity_name'] as String?) ?? '',
      timeLabel: (json['time_label'] as String?) ?? '',
      badgeText: (json['badge_text'] as String?) ?? 'Win',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
