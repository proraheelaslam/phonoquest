import 'dart:convert';

class TeacherDashboardPayload {
  final String subtitle;
  final ClassMasteryStats classMastery;
  final MilestoneInfo? milestone;
  final List<ActiveModuleCard> activeModules;
  final List<StudentSpotlightCard> studentSpotlight;
  final List<TeacherRecentActivity> recentActivities;
  final List<TeacherQuickLink> quickLinks;
  final bool hasStudentActivity;

  const TeacherDashboardPayload({
    required this.subtitle,
    required this.classMastery,
    required this.milestone,
    required this.activeModules,
    required this.studentSpotlight,
    required this.recentActivities,
    required this.quickLinks,
    required this.hasStudentActivity,
  });

  factory TeacherDashboardPayload.fromJson(Map<String, dynamic> json) {
    final modules = json['active_modules'];
    final spotlight = json['student_spotlight'];
    final activities = json['recent_activities'];
    final links = json['quick_links'];
    final mastery = json['class_mastery'];
    final milestoneJson = json['milestone'];

    return TeacherDashboardPayload(
      subtitle: (json['subtitle'] as String?) ?? '',
      classMastery: mastery is Map<String, dynamic>
          ? ClassMasteryStats.fromJson(mastery)
          : const ClassMasteryStats(
              avgPhonicsProficiency: 0,
              activeExplorers: 0,
              totalClasses: 0,
              rosterCount: 0,
            ),
      milestone: milestoneJson is Map<String, dynamic>
          ? MilestoneInfo.fromJson(milestoneJson)
          : null,
      activeModules: modules is List
          ? modules
              .whereType<Map<String, dynamic>>()
              .map(ActiveModuleCard.fromJson)
              .toList()
          : const [],
      studentSpotlight: spotlight is List
          ? spotlight
              .whereType<Map<String, dynamic>>()
              .map(StudentSpotlightCard.fromJson)
              .toList()
          : const [],
      recentActivities: activities is List
          ? activities
              .whereType<Map<String, dynamic>>()
              .map(TeacherRecentActivity.fromJson)
              .toList()
          : const [],
      quickLinks: links is List
          ? links
              .whereType<Map<String, dynamic>>()
              .map(TeacherQuickLink.fromJson)
              .toList()
          : const [],
      hasStudentActivity: json['has_student_activity'] == true,
    );
  }

  static TeacherDashboardPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid teacher dashboard payload.');
    }
    return TeacherDashboardPayload.fromJson(data);
  }
}

class ClassMasteryStats {
  final int avgPhonicsProficiency;
  final int activeExplorers;
  final int totalClasses;
  final int rosterCount;
  final int? selectedClassId;
  final String? selectedClassName;

  const ClassMasteryStats({
    required this.avgPhonicsProficiency,
    required this.activeExplorers,
    required this.totalClasses,
    required this.rosterCount,
    this.selectedClassId,
    this.selectedClassName,
  });

  factory ClassMasteryStats.fromJson(Map<String, dynamic> json) {
    return ClassMasteryStats(
      avgPhonicsProficiency: _asInt(json['avg_phonics_proficiency']),
      activeExplorers: _asInt(json['active_explorers']),
      totalClasses: _asInt(json['total_classes']),
      rosterCount: _asInt(json['roster_count']),
      selectedClassId: json['selected_class_id'] == null
          ? null
          : _asInt(json['selected_class_id']),
      selectedClassName: json['selected_class_name'] as String?,
    );
  }
}

class MilestoneInfo {
  final String title;
  final String description;
  final String reportLabel;

  const MilestoneInfo({
    required this.title,
    required this.description,
    required this.reportLabel,
  });

  factory MilestoneInfo.fromJson(Map<String, dynamic> json) {
    return MilestoneInfo(
      title: (json['title'] as String?) ?? 'Milestone Reached',
      description: (json['description'] as String?) ?? '',
      reportLabel:
          (json['report_label'] as String?) ?? 'VIEW CELEBRATION REPORT',
    );
  }
}

class ActiveModuleCard {
  final String moduleCode;
  final String title;
  final String description;
  final int progressPercent;
  final String status;
  final int studentCount;
  final String moduleInfo;

  const ActiveModuleCard({
    required this.moduleCode,
    required this.title,
    required this.description,
    required this.progressPercent,
    required this.status,
    required this.studentCount,
    required this.moduleInfo,
  });

  factory ActiveModuleCard.fromJson(Map<String, dynamic> json) {
    return ActiveModuleCard(
      moduleCode: (json['module_code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      progressPercent: _asInt(json['progress_percent']),
      status: (json['status'] as String?) ?? 'Not Started',
      studentCount: _asInt(json['student_count']),
      moduleInfo: (json['module_info'] as String?) ?? '',
    );
  }
}

class StudentSpotlightCard {
  final int studentId;
  final String studentName;
  final String? className;
  final int masteryPercent;
  final String badgeLabel;
  final String note;

  const StudentSpotlightCard({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.masteryPercent,
    required this.badgeLabel,
    required this.note,
  });

  factory StudentSpotlightCard.fromJson(Map<String, dynamic> json) {
    return StudentSpotlightCard(
      studentId: _asInt(json['student_id']),
      studentName: (json['student_name'] as String?) ?? 'Student',
      className: json['class_name'] as String?,
      masteryPercent: _asInt(json['mastery_percent']),
      badgeLabel: (json['badge_label'] as String?) ?? 'Explorer',
      note: (json['note'] as String?) ?? '',
    );
  }

  String get shortName {
    final parts = studentName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return studentName;
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last[0]}.';
  }
}

class TeacherRecentActivity {
  final String studentName;
  final String actionVerb;
  final String activityName;
  final String timeInfo;
  final String badgeType;
  final String badgeText;

  const TeacherRecentActivity({
    required this.studentName,
    required this.actionVerb,
    required this.activityName,
    required this.timeInfo,
    required this.badgeType,
    required this.badgeText,
  });

  factory TeacherRecentActivity.fromJson(Map<String, dynamic> json) {
    return TeacherRecentActivity(
      studentName: (json['student_name'] as String?) ?? 'Student',
      actionVerb: (json['action_verb'] as String?) ?? 'completed',
      activityName: (json['activity_name'] as String?) ?? '',
      timeInfo: (json['time_info'] as String?) ?? '',
      badgeType: (json['badge_type'] as String?) ?? 'xp',
      badgeText: (json['badge_text'] as String?) ?? '',
    );
  }
}

class TeacherQuickLink {
  final String title;
  final String url;
  final String icon;
  final String action;

  const TeacherQuickLink({
    required this.title,
    required this.url,
    required this.icon,
    required this.action,
  });

  factory TeacherQuickLink.fromJson(Map<String, dynamic> json) {
    return TeacherQuickLink(
      title: (json['title'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '',
      action: (json['action'] as String?) ?? 'Explore  →',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
