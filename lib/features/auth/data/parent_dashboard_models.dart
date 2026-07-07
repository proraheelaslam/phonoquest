import 'dart:convert';

class ParentDashboardPayload {
  final String childName;
  final String childSubtitle;
  final bool childLinked;
  final String? childQuestCode;
  final TodayGoalCard todayGoal;
  final List<ParentStatCard> statCards;
  final List<WeeklyProgressBar> weeklyProgress;
  final String weeklyProgressTrailing;
  final List<ParentMilestone> milestones;
  final String milestonesTrailing;
  final List<WeeklyReportItem> weeklyReports;
  final PremiumPlanCard premium;
  final String parentingTip;
  final bool hasChildActivity;
  final int unreadTeacherMessageCount;

  const ParentDashboardPayload({
    required this.childName,
    required this.childSubtitle,
    required this.childLinked,
    required this.childQuestCode,
    required this.todayGoal,
    required this.statCards,
    required this.weeklyProgress,
    required this.weeklyProgressTrailing,
    required this.milestones,
    required this.milestonesTrailing,
    required this.weeklyReports,
    required this.premium,
    required this.parentingTip,
    required this.hasChildActivity,
    required this.unreadTeacherMessageCount,
  });

  factory ParentDashboardPayload.fromJson(Map<String, dynamic> json) {
    final goal = json['today_goal'];
    final stats = json['stat_cards'];
    final bars = json['weekly_progress'];
    final milestones = json['milestones'];
    final reports = json['weekly_reports'];
    final premium = json['premium'];
    final tip = json['parenting_tip'];

    return ParentDashboardPayload(
      childName: (json['child_name'] as String?) ?? 'your child',
      childSubtitle: (json['child_subtitle'] as String?) ?? '',
      childLinked: json['child_linked'] == true,
      childQuestCode: json['child_quest_code'] as String?,
      todayGoal: goal is Map<String, dynamic>
          ? TodayGoalCard.fromJson(goal)
          : const TodayGoalCard(
              title: 'Finish 3 Phonics Tiles',
              description: '',
              completedCount: 0,
              targetCount: 3,
              progressPct: 0,
              progressLabel: '0% Completed',
              totalPoints: 0,
            ),
      statCards: stats is List
          ? stats
              .whereType<Map<String, dynamic>>()
              .map(ParentStatCard.fromJson)
              .toList()
          : const [],
      weeklyProgress: bars is List
          ? bars
              .whereType<Map<String, dynamic>>()
              .map(WeeklyProgressBar.fromJson)
              .toList()
          : const [],
      weeklyProgressTrailing:
          (json['weekly_progress_trailing'] as String?) ?? 'View Full Analytics',
      milestones: milestones is List
          ? milestones
              .whereType<Map<String, dynamic>>()
              .map(ParentMilestone.fromJson)
              .toList()
          : const [],
      milestonesTrailing:
          (json['milestones_trailing'] as String?) ?? 'See all',
      weeklyReports: reports is List
          ? reports
              .whereType<Map<String, dynamic>>()
              .map(WeeklyReportItem.fromJson)
              .toList()
          : const [],
      premium: premium is Map<String, dynamic>
          ? PremiumPlanCard.fromJson(premium)
          : const PremiumPlanCard(
              title: 'Premium Plan',
              description: '',
              actionLabel: 'Subscription Management →',
            ),
      parentingTip: tip is Map<String, dynamic>
          ? (tip['text'] as String?) ?? ''
          : '',
      hasChildActivity: json['has_child_activity'] == true,
      unreadTeacherMessageCount: _asInt(json['unread_teacher_message_count']),
    );
  }

  static ParentDashboardPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid parent dashboard payload.');
    }
    return ParentDashboardPayload.fromJson(data);
  }
}

class TodayGoalCard {
  final String pillLabel;
  final String title;
  final String description;
  final int completedCount;
  final int targetCount;
  final int progressPct;
  final String progressLabel;
  final int totalPoints;

  const TodayGoalCard({
    this.pillLabel = "Today's Goal",
    required this.title,
    required this.description,
    required this.completedCount,
    required this.targetCount,
    required this.progressPct,
    required this.progressLabel,
    required this.totalPoints,
  });

  factory TodayGoalCard.fromJson(Map<String, dynamic> json) {
    return TodayGoalCard(
      pillLabel: (json['pill_label'] as String?) ?? "Today's Goal",
      title: (json['title'] as String?) ?? 'Finish 3 Phonics Tiles',
      description: (json['description'] as String?) ?? '',
      completedCount: _asInt(json['completed_count']),
      targetCount: _asInt(json['target_count'], fallback: 3),
      progressPct: _asInt(json['progress_pct']),
      progressLabel: (json['progress_label'] as String?) ?? '0% Completed',
      totalPoints: _asInt(json['total_points']),
    );
  }

  double get progressValue {
    if (targetCount <= 0) return 0;
    return (completedCount / targetCount).clamp(0.0, 1.0);
  }
}

class ParentStatCard {
  final String key;
  final String title;
  final String value;
  final String subtitle;
  final bool trendPositive;

  const ParentStatCard({
    required this.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendPositive,
  });

  factory ParentStatCard.fromJson(Map<String, dynamic> json) {
    return ParentStatCard(
      key: (json['key'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      value: (json['value'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      trendPositive: json['trend_positive'] != false,
    );
  }
}

class WeeklyProgressBar {
  final String dayLabel;
  final double barHeight;
  final String colorToken;

  const WeeklyProgressBar({
    required this.dayLabel,
    required this.barHeight,
    required this.colorToken,
  });

  factory WeeklyProgressBar.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressBar(
      dayLabel: (json['day_label'] as String?) ?? '',
      barHeight: _asDouble(json['bar_height']),
      colorToken: (json['color_token'] as String?) ?? 'blue',
    );
  }
}

class ParentMilestone {
  final String icon;
  final String title;
  final String subtitle;
  final String dateLabel;

  const ParentMilestone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
  });

  factory ParentMilestone.fromJson(Map<String, dynamic> json) {
    return ParentMilestone(
      icon: (json['icon'] as String?) ?? 'trophy',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      dateLabel: (json['date_label'] as String?) ?? '',
    );
  }
}

class WeeklyReportItem {
  final String periodLabel;
  final String subtitle;

  const WeeklyReportItem({
    required this.periodLabel,
    required this.subtitle,
  });

  factory WeeklyReportItem.fromJson(Map<String, dynamic> json) {
    return WeeklyReportItem(
      periodLabel: (json['period_label'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? 'Summary Report',
    );
  }
}

class PremiumPlanCard {
  final String title;
  final String description;
  final String actionLabel;

  const PremiumPlanCard({
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  factory PremiumPlanCard.fromJson(Map<String, dynamic> json) {
    return PremiumPlanCard(
      title: (json['title'] as String?) ?? 'Premium Plan',
      description: (json['description'] as String?) ?? '',
      actionLabel: (json['action_label'] as String?) ?? 'Subscription Management →',
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse('$value') ?? fallback;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 28;
}
