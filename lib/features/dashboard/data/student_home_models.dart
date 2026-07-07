import 'dart:convert';

class StudentHomePayload {
  final int coins;
  final int progressPct;
  final String dailyMinutesLabel;
  final String wordsMasteredLabel;
  final ActiveModuleCard activeModule;
  final TeacherAssignmentCard? teacherAssignment;
  final List<AdventureModule> adventures;
  final int pendingAssignmentCount;

  const StudentHomePayload({
    required this.coins,
    required this.progressPct,
    required this.dailyMinutesLabel,
    required this.wordsMasteredLabel,
    required this.activeModule,
    this.teacherAssignment,
    required this.adventures,
    required this.pendingAssignmentCount,
  });

  factory StudentHomePayload.fromJson(Map<String, dynamic> json) {
    final activeJson = json['active_module'];
    final assignmentJson = json['teacher_assignment'];
    final adventuresJson = json['adventures'];

    return StudentHomePayload(
      coins: _asInt(json['coins']),
      progressPct: _asInt(json['progress_pct']),
      dailyMinutesLabel: (json['daily_minutes_label'] as String?) ?? '',
      wordsMasteredLabel: (json['words_mastered_label'] as String?) ?? '',
      activeModule: activeJson is Map<String, dynamic>
          ? ActiveModuleCard.fromJson(activeJson)
          : ActiveModuleCard.fallback(_asInt(json['progress_pct'])),
      teacherAssignment: assignmentJson is Map<String, dynamic>
          ? TeacherAssignmentCard.fromJson(assignmentJson)
          : null,
      adventures: adventuresJson is List
          ? adventuresJson.whereType<Map<String, dynamic>>().map(AdventureModule.fromJson).toList()
          : const [],
      pendingAssignmentCount: _asInt(json['pending_assignment_count']),
    );
  }

  static StudentHomePayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid student home payload.');
    }
    return StudentHomePayload.fromJson(data);
  }
}

class ActiveModuleCard {
  final String code;
  final String title;
  final String message;
  final int progressPct;
  final String ctaLabel;
  final String route;
  final String? subtitle;

  const ActiveModuleCard({
    required this.code,
    required this.title,
    required this.message,
    required this.progressPct,
    required this.ctaLabel,
    required this.route,
    this.subtitle,
  });

  factory ActiveModuleCard.fromJson(Map<String, dynamic> json) {
    return ActiveModuleCard(
      code: (json['code'] as String?) ?? 'alphabet_lounge',
      title: (json['title'] as String?) ?? 'Alphabet Lounge',
      message: (json['message'] as String?) ?? 'Keep going!',
      progressPct: _asInt(json['progress_pct']),
      ctaLabel: (json['cta_label'] as String?) ?? 'Resume',
      route: (json['route'] as String?) ?? 'alphabet',
      subtitle: json['subtitle'] as String?,
    );
  }

  factory ActiveModuleCard.fallback(int progressPct) {
    return ActiveModuleCard(
      code: 'alphabet_lounge',
      title: 'Alphabet Lounge',
      message: 'Keep going! You are building strong letter sounds.',
      progressPct: progressPct,
      ctaLabel: 'Resume',
      route: 'alphabet',
    );
  }
}

class TeacherAssignmentCard {
  final int assignmentId;
  final String moduleCode;
  final String moduleTitle;
  final String route;
  final String? teacherNote;
  final String? dueLabel;
  final String? teacherName;
  final String completionStatus;
  final int scorePercent;

  const TeacherAssignmentCard({
    required this.assignmentId,
    required this.moduleCode,
    required this.moduleTitle,
    required this.route,
    this.teacherNote,
    this.dueLabel,
    this.teacherName,
    required this.completionStatus,
    required this.scorePercent,
  });

  factory TeacherAssignmentCard.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentCard(
      assignmentId: _asInt(json['assignment_id']),
      moduleCode: (json['module_code'] as String?) ?? '',
      moduleTitle: (json['module_title'] as String?) ?? 'Assigned Module',
      route: (json['route'] as String?) ?? 'alphabet',
      teacherNote: json['teacher_note'] as String?,
      dueLabel: json['due_label'] as String?,
      teacherName: json['teacher_name'] as String?,
      completionStatus: (json['completion_status'] as String?) ?? 'pending',
      scorePercent: _asInt(json['score_percent']),
    );
  }
}

class AdventureModule {
  final String code;
  final String title;
  final String description;
  final String linkLabel;
  final String route;
  final String? subtitle;
  final bool isLocked;
  final String? lockReason;
  final String? upgradeLabel;
  final String? upgradeAction;

  const AdventureModule({
    required this.code,
    required this.title,
    required this.description,
    required this.linkLabel,
    required this.route,
    this.subtitle,
    this.isLocked = false,
    this.lockReason,
    this.upgradeLabel,
    this.upgradeAction,
  });

  factory AdventureModule.fromJson(Map<String, dynamic> json) {
    return AdventureModule(
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      linkLabel: (json['link_label'] as String?) ?? (json['cta_label'] as String?) ?? 'Open',
      route: (json['route'] as String?) ?? 'alphabet',
      subtitle: json['subtitle'] as String?,
      isLocked: json['is_locked'] == true,
      lockReason: json['lock_reason'] as String?,
      upgradeLabel: json['upgrade_label'] as String?,
      upgradeAction: json['upgrade_action'] as String?,
    );
  }
}

class StudentNotificationItem {
  final String id;
  final String kind;
  final String title;
  final String body;
  final String timeLabel;
  final String? ctaLabel;
  final String? route;
  final bool isRead;

  const StudentNotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.ctaLabel,
    this.route,
    required this.isRead,
  });

  factory StudentNotificationItem.fromJson(Map<String, dynamic> json) {
    return StudentNotificationItem(
      id: (json['id'] as String?) ?? '',
      kind: (json['kind'] as String?) ?? 'activity',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      timeLabel: (json['time_label'] as String?) ?? '',
      ctaLabel: json['cta_label'] as String?,
      route: json['route'] as String?,
      isRead: json['is_read'] == true,
    );
  }

  static List<StudentNotificationItem> listFromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(StudentNotificationItem.fromJson).toList();
  }
}

class LearningAdventuresPayload {
  final int weeklyQuestGoalPct;
  final int coins;
  final String activeModuleCode;
  final List<AdventureModule> modules;

  const LearningAdventuresPayload({
    required this.weeklyQuestGoalPct,
    required this.coins,
    required this.activeModuleCode,
    required this.modules,
  });

  factory LearningAdventuresPayload.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'];
    return LearningAdventuresPayload(
      weeklyQuestGoalPct: _asInt(json['weekly_quest_goal_pct']),
      coins: _asInt(json['coins']),
      activeModuleCode: (json['active_module_code'] as String?) ?? 'alphabet_lounge',
      modules: modulesJson is List
          ? modulesJson.whereType<Map<String, dynamic>>().map(AdventureModule.fromJson).toList()
          : const [],
    );
  }

  static LearningAdventuresPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid learning adventures payload.');
    }
    return LearningAdventuresPayload.fromJson(data);
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
