import 'dart:convert';

class StudentProgressPayload {
  final int coins;
  final String headline;
  final String subtitle;
  final String activitiesLabel;
  final int accuracyPct;
  final int wordsPracticed;
  final String premiumLabel;
  final int phonicsAccuracyPct;
  final String phonicsAccuracyMessage;
  final List<WeeklyWordBuilt> weeklyWordsBuilt;
  final List<RecentActivity> recentActivities;

  const StudentProgressPayload({
    required this.coins,
    required this.headline,
    required this.subtitle,
    required this.activitiesLabel,
    required this.accuracyPct,
    required this.wordsPracticed,
    required this.premiumLabel,
    required this.phonicsAccuracyPct,
    required this.phonicsAccuracyMessage,
    required this.weeklyWordsBuilt,
    required this.recentActivities,
  });

  factory StudentProgressPayload.fromJson(Map<String, dynamic> json) {
    final weekly = json['weekly_words_built'];
    final activities = json['recent_activities'];
    return StudentProgressPayload(
      coins: _asInt(json['coins']),
      headline: (json['headline'] as String?) ?? 'Progress Dashboard',
      subtitle: (json['subtitle'] as String?) ?? '',
      activitiesLabel: (json['activities_label'] as String?) ?? '0/0',
      accuracyPct: _asInt(json['accuracy_pct']),
      wordsPracticed: _asInt(json['words_practiced']),
      premiumLabel: (json['premium_label'] as String?) ?? 'Trial',
      phonicsAccuracyPct: _asInt(json['phonics_accuracy_pct']),
      phonicsAccuracyMessage:
          (json['phonics_accuracy_message'] as String?) ?? '',
      weeklyWordsBuilt: weekly is List
          ? weekly
              .whereType<Map<String, dynamic>>()
              .map(WeeklyWordBuilt.fromJson)
              .toList()
          : const [],
      recentActivities: activities is List
          ? activities
              .whereType<Map<String, dynamic>>()
              .map(RecentActivity.fromJson)
              .toList()
          : const [],
    );
  }

  static StudentProgressPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid student progress payload.');
    }
    return StudentProgressPayload.fromJson(data);
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class WeeklyWordBuilt {
  final String dayLabel;
  final int count;
  final double barRatio;

  const WeeklyWordBuilt({
    required this.dayLabel,
    required this.count,
    required this.barRatio,
  });

  factory WeeklyWordBuilt.fromJson(Map<String, dynamic> json) {
    final ratio = json['bar_ratio'];
    return WeeklyWordBuilt(
      dayLabel: (json['day_label'] as String?) ?? '',
      count: StudentProgressPayload._asInt(json['count']),
      barRatio: ratio is num ? ratio.toDouble() : double.tryParse('$ratio') ?? 0,
    );
  }
}

class RecentActivity {
  final String activityType;
  final String title;
  final String category;
  final String timeLabel;

  const RecentActivity({
    required this.activityType,
    required this.title,
    required this.category,
    required this.timeLabel,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      activityType: (json['activity_type'] as String?) ?? 'game',
      title: (json['title'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      timeLabel: (json['time_label'] as String?) ?? '',
    );
  }

  static List<RecentActivity> listFromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! List) {
      throw FormatException('Invalid activities payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(RecentActivity.fromJson)
        .toList();
  }
}
