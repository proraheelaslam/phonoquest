import 'dart:convert';

Map<String, dynamic> _expectDataMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid student access payload.');
  }
  return data;
}

class PaceOption {
  final String code;
  final String title;
  final String subtitle;
  final String levelLabel;
  final bool isLocked;
  final String? lockReason;
  final String? upgradeLabel;
  final String? upgradeAction;
  final bool isCurrent;
  final String? summary;
  final List<String> features;
  final List<String> lockedFeatures;

  const PaceOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.levelLabel,
    required this.isLocked,
    this.lockReason,
    this.upgradeLabel,
    this.upgradeAction,
    this.isCurrent = false,
    this.summary,
    this.features = const [],
    this.lockedFeatures = const [],
  });

  factory PaceOption.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    final locked = json['locked_features'];
    return PaceOption(
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      levelLabel: (json['level_label'] as String?) ?? '',
      isLocked: json['is_locked'] == true,
      lockReason: json['lock_reason'] as String?,
      upgradeLabel: json['upgrade_label'] as String?,
      upgradeAction: json['upgrade_action'] as String?,
      isCurrent: json['is_current'] == true,
      summary: json['summary'] as String?,
      features: features is List ? features.whereType<String>().toList() : const [],
      lockedFeatures: locked is List ? locked.whereType<String>().toList() : const [],
    );
  }
}

class StudentAccess {
  final String planCode;
  final String planName;
  final bool isPremium;
  final String currentReadingLevel;
  final String paceLabel;
  final String? paceSummary;
  final List<String> features;
  final List<String> lockedFeatures;
  final bool canUpgrade;
  final String upgradeLabel;
  final String? upgradeMessage;
  final String? maxPaceCode;
  final bool inClass;
  final String planManagedBy;
  final bool canManageSubscription;
  final List<PaceOption> paceOptions;

  const StudentAccess({
    required this.planCode,
    required this.planName,
    required this.isPremium,
    required this.currentReadingLevel,
    required this.paceLabel,
    this.paceSummary,
    this.features = const [],
    this.lockedFeatures = const [],
    required this.canUpgrade,
    required this.upgradeLabel,
    this.upgradeMessage,
    this.maxPaceCode,
    this.inClass = false,
    this.planManagedBy = 'self',
    this.canManageSubscription = false,
    required this.paceOptions,
  });

  factory StudentAccess.fromJson(Map<String, dynamic> json) {
    final options = json['pace_options'];
    final features = json['features'];
    final locked = json['locked_features'];
    return StudentAccess(
      planCode: (json['plan_code'] as String?) ?? 'trial',
      planName: (json['plan_name'] as String?) ?? 'Trial Access',
      isPremium: json['is_premium'] == true,
      currentReadingLevel: (json['current_reading_level'] as String?) ?? 'beginner',
      paceLabel: (json['pace_label'] as String?) ?? 'Beginner',
      paceSummary: json['pace_summary'] as String?,
      features: features is List ? features.whereType<String>().toList() : const [],
      lockedFeatures: locked is List ? locked.whereType<String>().toList() : const [],
      canUpgrade: json['can_upgrade'] == true,
      upgradeLabel: (json['upgrade_label'] as String?) ?? 'Change pace',
      upgradeMessage: json['upgrade_message'] as String?,
      maxPaceCode: json['max_pace_code'] as String?,
      inClass: json['in_class'] == true,
      planManagedBy: (json['plan_managed_by'] as String?) ?? 'self',
      canManageSubscription: json['can_manage_subscription'] == true,
      paceOptions: options is List
          ? options.whereType<Map<String, dynamic>>().map(PaceOption.fromJson).toList()
          : const [],
    );
  }

  factory StudentAccess.fromRootJson(String body) {
    return StudentAccess.fromJson(_expectDataMap(body));
  }

  /// Signup — only Beginner is selectable; other paces unlock via subscription later.
  factory StudentAccess.signupDefaults() {
    return const StudentAccess(
      planCode: 'basic',
      planName: 'New student',
      isPremium: false,
      currentReadingLevel: 'beginner',
      paceLabel: 'Beginner',
      canUpgrade: false,
      upgradeLabel: 'Change pace',
      upgradeMessage:
          'Start with Beginner during signup. Unlock Intermediate and Advanced later from Settings with a subscription plan.',
      paceOptions: [
        PaceOption(
          code: 'beginner',
          title: 'Beginner',
          subtitle: 'Starting with sounds',
          levelLabel: 'Level 1',
          isLocked: false,
          isCurrent: true,
          summary: 'Starter phonics — perfect for first steps.',
          features: ['Alphabet Lounge', 'Letter sounds & starter games', 'Basic daily practice'],
          lockedFeatures: ['Blend Forest', 'Vowel Learning hub', 'Smart Chart & advanced modules'],
        ),
        PaceOption(
          code: 'intermediate',
          title: 'Intermediate',
          subtitle: 'Simple words',
          levelLabel: 'Level 5',
          isLocked: true,
          lockReason: 'Unlock Intermediate later with a subscription plan.',
          upgradeLabel: 'Available after signup',
          upgradeAction: 'subscription',
          summary: 'Core adventures for growing readers.',
          features: [
            'Alphabet Lounge',
            'Blend Forest',
            'Vowel Learning',
            'Progress tracking',
          ],
          lockedFeatures: ['Interactive Smart Chart', 'Sound Learning', 'Listen & Tap'],
        ),
        PaceOption(
          code: 'advanced',
          title: 'Advanced',
          subtitle: 'Full Stories',
          levelLabel: 'Level 10',
          isLocked: true,
          lockReason: 'Unlock Advanced later with a Premium subscription plan.',
          upgradeLabel: 'Available after signup',
          upgradeAction: 'subscription',
          summary: 'Full PhonoQuest library and tools.',
          features: [
            'All learning adventures',
            'Interactive Smart Chart',
            'Sound Learning',
            'Listen & Tap',
            'Full progress reports',
          ],
          lockedFeatures: [],
        ),
      ],
    );
  }
}

int paceIndexFromCode(String code) {
  switch (code.trim().toLowerCase()) {
    case 'intermediate':
      return 1;
    case 'advanced':
      return 2;
    case 'beginner':
    default:
      return 0;
  }
}
