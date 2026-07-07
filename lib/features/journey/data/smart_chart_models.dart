class SmartChartPayload {
  final String title;
  final String subtitle;
  final int coins;
  final List<SmartChartSection> sections;
  final String? playAllAudioUrl;

  const SmartChartPayload({
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.sections,
    this.playAllAudioUrl,
  });

  factory SmartChartPayload.fromJson(Map<String, dynamic> json) {
    final sectionsRaw = json['sections'];
    final sections = <SmartChartSection>[];
    if (sectionsRaw is List) {
      for (final section in sectionsRaw) {
        if (section is Map<String, dynamic>) {
          sections.add(SmartChartSection.fromJson(section));
        }
      }
    }

    return SmartChartPayload(
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      coins: json['coins'] is int ? json['coins'] as int : int.tryParse('${json['coins']}') ?? 0,
      sections: sections,
      playAllAudioUrl: json['play_all_audio_url'] as String?,
    );
  }
}

class SmartChartSection {
  final String id;
  final String title;
  final String theme;
  final List<SmartChartTile> tiles;

  const SmartChartSection({
    required this.id,
    required this.title,
    required this.theme,
    required this.tiles,
  });

  factory SmartChartSection.fromJson(Map<String, dynamic> json) {
    final tilesRaw = json['tiles'];
    final tiles = <SmartChartTile>[];
    if (tilesRaw is List) {
      for (final tile in tilesRaw) {
        if (tile is Map<String, dynamic>) {
          tiles.add(SmartChartTile.fromJson(tile));
        }
      }
    }

    return SmartChartSection(
      id: (json['id'] as String?) ?? '${json['id']}',
      title: (json['title'] as String?) ?? '',
      theme: (json['theme'] as String?) ?? '',
      tiles: tiles,
    );
  }
}

class SmartChartTile {
  final String code;
  final String label;
  final String exampleWord;
  final String? audioUrl;

  const SmartChartTile({
    required this.code,
    required this.label,
    required this.exampleWord,
    this.audioUrl,
  });

  factory SmartChartTile.fromJson(Map<String, dynamic> json) {
    return SmartChartTile(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      exampleWord: (json['example_word'] as String?) ?? '',
      audioUrl: json['audio_url'] as String?,
    );
  }
}
