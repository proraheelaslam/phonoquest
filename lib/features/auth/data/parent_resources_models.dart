import 'dart:convert';

class ParentResourcesPayload {
  final String pageTitle;
  final String pageSubtitle;
  final String featuredSectionTitle;
  final String printablesSectionTitle;
  final String tipsSectionTitle;
  final List<ResourceTab> tabs;
  final List<FeaturedResource> featured;
  final List<PrintableResource> printables;
  final List<ParentResourceTip> tips;
  final bool childLinked;
  final String? childName;
  final String? subscriptionPlanCode;
  final bool isPremium;
  final String? printablesLockedMessage;

  const ParentResourcesPayload({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.featuredSectionTitle,
    required this.printablesSectionTitle,
    required this.tipsSectionTitle,
    required this.tabs,
    required this.featured,
    required this.printables,
    required this.tips,
    required this.childLinked,
    required this.childName,
    this.subscriptionPlanCode,
    this.isPremium = false,
    this.printablesLockedMessage,
  });

  factory ParentResourcesPayload.fromJson(Map<String, dynamic> json) {
    final tabs = json['tabs'];
    final featured = json['featured'];
    final printables = json['printables'];
    final tips = json['tips'];

    return ParentResourcesPayload(
      pageTitle: (json['page_title'] as String?) ?? 'Resource Library',
      pageSubtitle: (json['page_subtitle'] as String?) ?? '',
      featuredSectionTitle:
          (json['featured_section_title'] as String?) ?? 'Featured for You',
      printablesSectionTitle:
          (json['printables_section_title'] as String?) ?? 'Printable Charts',
      tipsSectionTitle:
          (json['tips_section_title'] as String?) ?? 'Quick Parent Tips',
      tabs: tabs is List
          ? tabs.whereType<Map<String, dynamic>>().map(ResourceTab.fromJson).toList()
          : const [],
      featured: featured is List
          ? featured
              .whereType<Map<String, dynamic>>()
              .map(FeaturedResource.fromJson)
              .toList()
          : const [],
      printables: printables is List
          ? printables
              .whereType<Map<String, dynamic>>()
              .map(PrintableResource.fromJson)
              .toList()
          : const [],
      tips: tips is List
          ? tips
              .whereType<Map<String, dynamic>>()
              .map(ParentResourceTip.fromJson)
              .toList()
          : const [],
      childLinked: json['child_linked'] == true,
      childName: json['child_name'] as String?,
      subscriptionPlanCode: json['subscription_plan_code'] as String?,
      isPremium: json['is_premium'] == true,
      printablesLockedMessage: json['printables_locked_message'] as String?,
    );
  }

  static ParentResourcesPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid parent resources payload.');
    }
    return ParentResourcesPayload.fromJson(data);
  }
}

class ResourceTab {
  final String key;
  final String label;

  const ResourceTab({required this.key, required this.label});

  factory ResourceTab.fromJson(Map<String, dynamic> json) {
    return ResourceTab(
      key: (json['key'] as String?) ?? 'all',
      label: (json['label'] as String?) ?? 'All Resources',
    );
  }
}

class FeaturedResource {
  final String id;
  final String kind;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String durationLabel;
  final bool isVideo;
  final String body;
  final String? videoUrl;

  const FeaturedResource({
    required this.id,
    required this.kind,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.durationLabel,
    required this.isVideo,
    required this.body,
    this.videoUrl,
  });

  factory FeaturedResource.fromJson(Map<String, dynamic> json) {
    return FeaturedResource(
      id: (json['id'] as String?) ?? '',
      kind: (json['kind'] as String?) ?? 'guide',
      imageAsset: (json['image_asset'] as String?) ?? 'sunnyimage',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      durationLabel: (json['duration_label'] as String?) ?? '',
      isVideo: json['is_video'] == true,
      body: (json['body'] as String?) ?? '',
      videoUrl: json['video_url'] as String?,
    );
  }
}

class PrintableResource {
  final String id;
  final String imageAsset;
  final String title;
  final String fileLabel;
  final String description;
  final String downloadPath;
  final String previewPath;
  final bool isLocked;
  final String? lockReason;

  const PrintableResource({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.fileLabel,
    required this.description,
    required this.downloadPath,
    required this.previewPath,
    this.isLocked = false,
    this.lockReason,
  });

  factory PrintableResource.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    final defaultPath = 'dashboard/parent/resources/printables/$id/download';
    return PrintableResource(
      id: id,
      imageAsset: (json['image_asset'] as String?) ?? 'exploreimage',
      title: (json['title'] as String?) ?? '',
      fileLabel: (json['file_label'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      downloadPath: (json['download_path'] as String?) ?? defaultPath,
      previewPath: (json['preview_path'] as String?) ??
          (json['download_path'] as String?) ??
          defaultPath,
      isLocked: json['is_locked'] == true,
      lockReason: json['lock_reason'] as String?,
    );
  }
}

class ParentResourceTip {
  final String id;
  final String icon;
  final String bgColor;
  final String title;
  final String text;

  const ParentResourceTip({
    required this.id,
    required this.icon,
    required this.bgColor,
    required this.title,
    required this.text,
  });

  factory ParentResourceTip.fromJson(Map<String, dynamic> json) {
    return ParentResourceTip(
      id: (json['id'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? 'lightbulb',
      bgColor: (json['bg_color'] as String?) ?? 'blue_soft',
      title: (json['title'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
    );
  }
}
