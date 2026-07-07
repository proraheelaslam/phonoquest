import 'dart:convert';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

Map<String, dynamic> _expectDataMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid assignment payload.');
  }
  return data;
}

class ModuleCatalogItem {
  final String code;
  final String title;
  final String? subtitle;
  final String? description;
  final String levelLabel;
  final int levelNumber;
  final int sortOrder;

  const ModuleCatalogItem({
    required this.code,
    required this.title,
    this.subtitle,
    this.description,
    required this.levelLabel,
    required this.levelNumber,
    required this.sortOrder,
  });

  factory ModuleCatalogItem.fromJson(Map<String, dynamic> json) {
    return ModuleCatalogItem(
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      levelLabel: (json['level_label'] as String?) ?? 'Level 1',
      levelNumber: _asInt(json['level_number'], 1),
      sortOrder: _asInt(json['sort_order']),
    );
  }
}

class RecentlyAssignedItem {
  final int assignmentId;
  final String moduleCode;
  final String moduleTitle;
  final String? description;
  final int assignedDaysAgo;
  final String recipientSummary;
  final int? classId;
  final String? className;

  const RecentlyAssignedItem({
    required this.assignmentId,
    required this.moduleCode,
    required this.moduleTitle,
    this.description,
    required this.assignedDaysAgo,
    required this.recipientSummary,
    this.classId,
    this.className,
  });

  factory RecentlyAssignedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyAssignedItem(
      assignmentId: _asInt(json['assignment_id']),
      moduleCode: (json['module_code'] as String?) ?? '',
      moduleTitle: (json['module_title'] as String?) ?? '',
      description: json['description'] as String?,
      assignedDaysAgo: _asInt(json['assigned_days_ago']),
      recipientSummary: (json['recipient_summary'] as String?) ?? '',
      classId: json['class_id'] == null ? null : _asInt(json['class_id']),
      className: json['class_name'] as String?,
    );
  }
}

class TeacherModulesCatalog {
  final List<ModuleCatalogItem> modules;
  final List<RecentlyAssignedItem> recentlyAssigned;

  const TeacherModulesCatalog({
    required this.modules,
    required this.recentlyAssigned,
  });

  factory TeacherModulesCatalog.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'];
    final recentJson = json['recently_assigned'];
    return TeacherModulesCatalog(
      modules: modulesJson is List
          ? modulesJson.whereType<Map<String, dynamic>>().map(ModuleCatalogItem.fromJson).toList()
          : const [],
      recentlyAssigned: recentJson is List
          ? recentJson.whereType<Map<String, dynamic>>().map(RecentlyAssignedItem.fromJson).toList()
          : const [],
    );
  }

  static TeacherModulesCatalog fromRootJson(String body) {
    return TeacherModulesCatalog.fromJson(_expectDataMap(body));
  }
}

class ClassRecipient {
  final int id;
  final String name;
  final int studentCount;
  final String? gradeLevel;

  const ClassRecipient({
    required this.id,
    required this.name,
    required this.studentCount,
    this.gradeLevel,
  });

  factory ClassRecipient.fromJson(Map<String, dynamic> json) {
    return ClassRecipient(
      id: _asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      studentCount: _asInt(json['student_count']),
      gradeLevel: json['grade_level'] as String?,
    );
  }
}

class IndividualRecipient {
  final int rosterId;
  final String displayName;
  final int classId;
  final String className;
  final int? learnerUserId;
  final int missingCount;
  final String statusGroup;

  const IndividualRecipient({
    required this.rosterId,
    required this.displayName,
    required this.classId,
    required this.className,
    this.learnerUserId,
    required this.missingCount,
    required this.statusGroup,
  });

  bool get isCatchUp => statusGroup == 'catch_up_required';

  factory IndividualRecipient.fromJson(Map<String, dynamic> json) {
    return IndividualRecipient(
      rosterId: _asInt(json['roster_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      classId: _asInt(json['class_id']),
      className: (json['class_name'] as String?) ?? '',
      learnerUserId: json['learner_user_id'] == null ? null : _asInt(json['learner_user_id']),
      missingCount: _asInt(json['missing_count']),
      statusGroup: (json['status_group'] as String?) ?? 'on_track',
    );
  }
}

class AssignmentRecipientsPayload {
  final String? moduleCode;
  final String? moduleTitle;
  final List<ClassRecipient> classes;
  final List<IndividualRecipient> catchUpRequired;
  final List<IndividualRecipient> onTrack;

  const AssignmentRecipientsPayload({
    this.moduleCode,
    this.moduleTitle,
    required this.classes,
    required this.catchUpRequired,
    required this.onTrack,
  });

  factory AssignmentRecipientsPayload.fromJson(Map<String, dynamic> json) {
    final grouped = json['grouped'];
    List<IndividualRecipient> catchUp = const [];
    List<IndividualRecipient> onTrack = const [];
    if (grouped is Map<String, dynamic>) {
      final catchJson = grouped['catch_up_required'];
      final trackJson = grouped['on_track'];
      catchUp = catchJson is List
          ? catchJson.whereType<Map<String, dynamic>>().map(IndividualRecipient.fromJson).toList()
          : const [];
      onTrack = trackJson is List
          ? trackJson.whereType<Map<String, dynamic>>().map(IndividualRecipient.fromJson).toList()
          : const [];
    }

    final classesJson = json['classes'];
    return AssignmentRecipientsPayload(
      moduleCode: json['module_code'] as String?,
      moduleTitle: json['module_title'] as String?,
      classes: classesJson is List
          ? classesJson.whereType<Map<String, dynamic>>().map(ClassRecipient.fromJson).toList()
          : const [],
      catchUpRequired: catchUp,
      onTrack: onTrack,
    );
  }

  static AssignmentRecipientsPayload fromRootJson(String body) {
    return AssignmentRecipientsPayload.fromJson(_expectDataMap(body));
  }
}

class AssignmentDetail {
  final int id;
  final String moduleCode;
  final String moduleTitle;
  final String? moduleDescription;
  final String levelLabel;
  final String recipientMode;
  final int? classId;
  final String? className;
  final String? recipientSummary;
  final int studentCount;
  final DateTime? scheduleDueAt;
  final String? scheduleDueLabel;
  final String? teacherNote;
  final String status;
  final int? assignedDaysAgo;

  const AssignmentDetail({
    required this.id,
    required this.moduleCode,
    required this.moduleTitle,
    this.moduleDescription,
    required this.levelLabel,
    required this.recipientMode,
    this.classId,
    this.className,
    this.recipientSummary,
    required this.studentCount,
    this.scheduleDueAt,
    this.scheduleDueLabel,
    this.teacherNote,
    required this.status,
    this.assignedDaysAgo,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {
    DateTime? dueAt;
    final rawDue = json['schedule_due_at'];
    if (rawDue is String && rawDue.isNotEmpty) {
      dueAt = DateTime.tryParse(rawDue);
    }

    return AssignmentDetail(
      id: _asInt(json['id']),
      moduleCode: (json['module_code'] as String?) ?? '',
      moduleTitle: (json['module_title'] as String?) ?? '',
      moduleDescription: json['module_description'] as String?,
      levelLabel: (json['level_label'] as String?) ?? '',
      recipientMode: (json['recipient_mode'] as String?) ?? 'entire_class',
      classId: json['class_id'] == null ? null : _asInt(json['class_id']),
      className: json['class_name'] as String?,
      recipientSummary: json['recipient_summary'] as String?,
      studentCount: _asInt(json['student_count']),
      scheduleDueAt: dueAt,
      scheduleDueLabel: json['schedule_due_label'] as String?,
      teacherNote: json['teacher_note'] as String?,
      status: (json['status'] as String?) ?? 'active',
      assignedDaysAgo: json['assigned_days_ago'] == null ? null : _asInt(json['assigned_days_ago']),
    );
  }

  static AssignmentDetail fromRootJson(String body) {
    return AssignmentDetail.fromJson(_expectDataMap(body));
  }

  static List<AssignmentDetail> listFromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! List) {
      throw const FormatException('Invalid assignments list payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AssignmentDetail.fromJson)
        .toList();
  }

  bool get isActive => status == 'active';

  bool get isCancelled => status == 'cancelled';
}

class ScoreDistributionBucket {
  final String label;
  final int studentCount;

  const ScoreDistributionBucket({required this.label, required this.studentCount});

  factory ScoreDistributionBucket.fromJson(Map<String, dynamic> json) {
    return ScoreDistributionBucket(
      label: (json['label'] as String?) ?? '',
      studentCount: _asInt(json['student_count']),
    );
  }
}

class CommonStruggle {
  final String label;
  final int studentCount;

  const CommonStruggle({required this.label, required this.studentCount});

  factory CommonStruggle.fromJson(Map<String, dynamic> json) {
    return CommonStruggle(
      label: (json['label'] as String?) ?? '',
      studentCount: _asInt(json['student_count']),
    );
  }
}

class AssignmentAnalyticsStudent {
  final int rosterId;
  final String displayName;
  final String initials;
  final int scorePercent;
  final String completionStatus;

  const AssignmentAnalyticsStudent({
    required this.rosterId,
    required this.displayName,
    required this.initials,
    required this.scorePercent,
    required this.completionStatus,
  });

  factory AssignmentAnalyticsStudent.fromJson(Map<String, dynamic> json) {
    return AssignmentAnalyticsStudent(
      rosterId: _asInt(json['roster_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      initials: (json['initials'] as String?) ?? '?',
      scorePercent: _asInt(json['score_percent']),
      completionStatus: (json['completion_status'] as String?) ?? 'pending',
    );
  }
}

class AssignmentAnalytics {
  final int assignmentId;
  final String moduleTitle;
  final String? completedOnLabel;
  final int completionPercent;
  final int completedCount;
  final int totalCount;
  final int avgAccuracyPercent;
  final List<CommonStruggle> commonStruggles;
  final List<ScoreDistributionBucket> scoreDistribution;
  final List<AssignmentAnalyticsStudent> students;

  const AssignmentAnalytics({
    required this.assignmentId,
    required this.moduleTitle,
    this.completedOnLabel,
    required this.completionPercent,
    required this.completedCount,
    required this.totalCount,
    required this.avgAccuracyPercent,
    required this.commonStruggles,
    required this.scoreDistribution,
    required this.students,
  });

  factory AssignmentAnalytics.fromJson(Map<String, dynamic> json) {
    final strugglesJson = json['common_struggles'];
    final bucketsJson = json['score_distribution'];
    final studentsJson = json['students'];

    return AssignmentAnalytics(
      assignmentId: _asInt(json['assignment_id']),
      moduleTitle: (json['module_title'] as String?) ?? '',
      completedOnLabel: json['completed_on_label'] as String?,
      completionPercent: _asInt(json['completion_percent']),
      completedCount: _asInt(json['completed_count']),
      totalCount: _asInt(json['total_count']),
      avgAccuracyPercent: _asInt(json['avg_accuracy_percent']),
      commonStruggles: strugglesJson is List
          ? strugglesJson.whereType<Map<String, dynamic>>().map(CommonStruggle.fromJson).toList()
          : const [],
      scoreDistribution: bucketsJson is List
          ? bucketsJson.whereType<Map<String, dynamic>>().map(ScoreDistributionBucket.fromJson).toList()
          : const [],
      students: studentsJson is List
          ? studentsJson.whereType<Map<String, dynamic>>().map(AssignmentAnalyticsStudent.fromJson).toList()
          : const [],
    );
  }

  static AssignmentAnalytics fromRootJson(String body) {
    return AssignmentAnalytics.fromJson(_expectDataMap(body));
  }
}

class ReviewQueueItem {
  final int rosterId;
  final String displayName;
  final String moduleTitle;
  final String tagLabel;
  final String submittedLabel;
  final int assignmentId;
  final int scorePercent;

  const ReviewQueueItem({
    required this.rosterId,
    required this.displayName,
    required this.moduleTitle,
    required this.tagLabel,
    required this.submittedLabel,
    required this.assignmentId,
    required this.scorePercent,
  });

  factory ReviewQueueItem.fromJson(Map<String, dynamic> json) {
    return ReviewQueueItem(
      rosterId: _asInt(json['roster_id']),
      displayName: (json['display_name'] as String?) ?? 'Student',
      moduleTitle: (json['module_title'] as String?) ?? '',
      tagLabel: (json['tag_label'] as String?) ?? '',
      submittedLabel: (json['submitted_label'] as String?) ?? 'Submitted recently',
      assignmentId: _asInt(json['assignment_id']),
      scorePercent: _asInt(json['score_percent']),
    );
  }

  static List<ReviewQueueItem> listFromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! List) {
      throw const FormatException('Invalid review queue payload.');
    }
    return data.whereType<Map<String, dynamic>>().map(ReviewQueueItem.fromJson).toList();
  }
}
