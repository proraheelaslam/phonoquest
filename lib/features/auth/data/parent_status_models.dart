import 'dart:convert';

class ParentStatusPayload {
  final ChildStatusHeader header;
  final JourneyProgress journey;
  final SoundMasteryCard soundMastery;
  final CurrentFocusCard currentFocus;
  final List<RecentQuestItem> recentQuests;
  final String recentQuestsTrailing;
  final int recentQuestsTotal;
  final bool hasChildActivity;

  const ParentStatusPayload({
    required this.header,
    required this.journey,
    required this.soundMastery,
    required this.currentFocus,
    required this.recentQuests,
    required this.recentQuestsTrailing,
    required this.recentQuestsTotal,
    required this.hasChildActivity,
  });

  factory ParentStatusPayload.fromJson(Map<String, dynamic> json) {
    final quests = json['recent_quests'];
    return ParentStatusPayload(
      header: json['header'] is Map<String, dynamic>
          ? ChildStatusHeader.fromJson(json['header'] as Map<String, dynamic>)
          : const ChildStatusHeader(
              childName: 'your child',
              levelSubtitle: '',
              introText: '',
              childLinked: false,
            ),
      journey: json['journey'] is Map<String, dynamic>
          ? JourneyProgress.fromJson(json['journey'] as Map<String, dynamic>)
          : const JourneyProgress(
              title: "Journey",
              description: '',
              overallMasteryPct: 0,
            ),
      soundMastery: json['sound_mastery'] is Map<String, dynamic>
          ? SoundMasteryCard.fromJson(json['sound_mastery'] as Map<String, dynamic>)
          : const SoundMasteryCard(
              statusLabel: '',
              statusTone: '',
              items: [],
            ),
      currentFocus: json['current_focus'] is Map<String, dynamic>
          ? CurrentFocusCard.fromJson(json['current_focus'] as Map<String, dynamic>)
          : const CurrentFocusCard(
              moduleTitle: 'Blend Forest',
              moduleCode: 'blend_forest',
              imageAsset: 'journeyimage',
              description: '',
              focusDetail: '',
            ),
      recentQuests: quests is List
          ? quests
              .whereType<Map<String, dynamic>>()
              .map(RecentQuestItem.fromJson)
              .toList()
          : const [],
      recentQuestsTrailing:
          (json['recent_quests_trailing'] as String?) ?? 'View All',
      recentQuestsTotal: _asInt(json['recent_quests_total']),
      hasChildActivity: json['has_child_activity'] == true,
    );
  }

  static ParentStatusPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid parent status payload.');
    }
    return ParentStatusPayload.fromJson(data);
  }
}

class ChildStatusHeader {
  final String childName;
  final String levelSubtitle;
  final String introText;
  final bool childLinked;

  const ChildStatusHeader({
    required this.childName,
    required this.levelSubtitle,
    required this.introText,
    required this.childLinked,
  });

  factory ChildStatusHeader.fromJson(Map<String, dynamic> json) {
    return ChildStatusHeader(
      childName: (json['child_name'] as String?) ?? 'your child',
      levelSubtitle: (json['level_subtitle'] as String?) ?? '',
      introText: (json['intro_text'] as String?) ?? '',
      childLinked: json['child_linked'] == true,
    );
  }
}

class JourneyProgress {
  final String sectionLabel;
  final String title;
  final String description;
  final int overallMasteryPct;
  final String masteryLabel;

  const JourneyProgress({
    this.sectionLabel = '📈  CHILD PROGRESS DETAIL',
    required this.title,
    required this.description,
    required this.overallMasteryPct,
    this.masteryLabel = 'OVERALL MASTERY',
  });

  factory JourneyProgress.fromJson(Map<String, dynamic> json) {
    return JourneyProgress(
      sectionLabel: (json['section_label'] as String?) ?? '📈  CHILD PROGRESS DETAIL',
      title: (json['title'] as String?) ?? 'Journey',
      description: (json['description'] as String?) ?? '',
      overallMasteryPct: _asInt(json['overall_mastery_pct']),
      masteryLabel: (json['mastery_label'] as String?) ?? 'OVERALL MASTERY',
    );
  }
}

class SoundMasteryItem {
  final String key;
  final String label;
  final int percent;
  final String trendIcon;

  const SoundMasteryItem({
    required this.key,
    required this.label,
    required this.percent,
    required this.trendIcon,
  });

  factory SoundMasteryItem.fromJson(Map<String, dynamic> json) {
    return SoundMasteryItem(
      key: (json['key'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      percent: _asInt(json['percent']),
      trendIcon: (json['trend_icon'] as String?) ?? 'sync',
    );
  }
}

class SoundMasteryCard {
  final String statusLabel;
  final String statusTone;
  final String title;
  final String subtitle;
  final List<SoundMasteryItem> items;

  const SoundMasteryCard({
    required this.statusLabel,
    required this.statusTone,
    this.title = 'Sound Mastery',
    this.subtitle = 'Proficiency across key phonetic categories.',
    required this.items,
  });

  factory SoundMasteryCard.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return SoundMasteryCard(
      statusLabel: (json['status_label'] as String?) ?? '',
      statusTone: (json['status_tone'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Sound Mastery',
      subtitle: (json['subtitle'] as String?) ?? '',
      items: items is List
          ? items
              .whereType<Map<String, dynamic>>()
              .map(SoundMasteryItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class CurrentFocusCard {
  final String moduleTitle;
  final String moduleCode;
  final String imageAsset;
  final String description;
  final String focusDetail;
  final String ctaLabel;

  const CurrentFocusCard({
    required this.moduleTitle,
    required this.moduleCode,
    required this.imageAsset,
    required this.description,
    required this.focusDetail,
    this.ctaLabel = 'Assign Practice  >',
  });

  factory CurrentFocusCard.fromJson(Map<String, dynamic> json) {
    return CurrentFocusCard(
      moduleTitle: (json['module_title'] as String?) ?? 'Blend Forest',
      moduleCode: (json['module_code'] as String?) ?? 'blend_forest',
      imageAsset: (json['image_asset'] as String?) ?? 'journeyimage',
      description: (json['description'] as String?) ?? '',
      focusDetail: (json['focus_detail'] as String?) ?? '',
      ctaLabel: (json['cta_label'] as String?) ?? 'Assign Practice  >',
    );
  }
}

class ParentRecentQuestsPayload {
  final String pageTitle;
  final String pageSubtitle;
  final bool childLinked;
  final String childName;
  final List<RecentQuestItem> quests;
  final int totalCount;

  const ParentRecentQuestsPayload({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.childLinked,
    required this.childName,
    required this.quests,
    required this.totalCount,
  });

  factory ParentRecentQuestsPayload.fromJson(Map<String, dynamic> json) {
    final quests = json['quests'];
    return ParentRecentQuestsPayload(
      pageTitle: (json['page_title'] as String?) ?? 'Recent Quests',
      pageSubtitle: (json['page_subtitle'] as String?) ?? '',
      childLinked: json['child_linked'] == true,
      childName: (json['child_name'] as String?) ?? 'your child',
      quests: quests is List
          ? quests
              .whereType<Map<String, dynamic>>()
              .map(RecentQuestItem.fromJson)
              .toList()
          : const [],
      totalCount: _asInt(json['total_count']),
    );
  }

  static ParentRecentQuestsPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid recent quests payload.');
    }
    return ParentRecentQuestsPayload.fromJson(data);
  }
}

class RecentQuestItem {
  final String icon;
  final String timeLabel;
  final String title;
  final String subtitle;
  final String badge;
  final bool reviewed;

  const RecentQuestItem({
    required this.icon,
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.reviewed,
  });

  factory RecentQuestItem.fromJson(Map<String, dynamic> json) {
    return RecentQuestItem(
      icon: (json['icon'] as String?) ?? 'star',
      timeLabel: (json['time_label'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      badge: (json['badge'] as String?) ?? '',
      reviewed: json['reviewed'] == true,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
