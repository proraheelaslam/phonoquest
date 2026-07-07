import 'dart:convert';

class BlendLessonModel {
  final int id;
  final String code;
  final String title;
  final String soundLabel;
  final String? iconUrl;
  final String? audioUrl;
  final String exampleWordsPill;
  final int masteryPercent;
  final String status;
  final List<BlendWordModel> words;

  const BlendLessonModel({
    required this.id,
    required this.code,
    required this.title,
    required this.soundLabel,
    this.iconUrl,
    this.audioUrl,
    required this.exampleWordsPill,
    required this.masteryPercent,
    required this.status,
    this.words = const [],
  });

  factory BlendLessonModel.fromJson(Map<String, dynamic> json) {
    final wordsRaw = json['words'];
    final words = <BlendWordModel>[];
    if (wordsRaw is List) {
      for (final entry in wordsRaw) {
        if (entry is Map<String, dynamic>) {
          words.add(BlendWordModel.fromJson(entry));
        }
      }
    }
    return BlendLessonModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      soundLabel: (json['sound_label'] as String?) ?? '',
      iconUrl: json['icon_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      exampleWordsPill: (json['example_words_pill'] as String?) ?? '',
      masteryPercent: json['mastery_percent'] is int ? json['mastery_percent'] as int : int.tryParse('${json['mastery_percent']}') ?? 0,
      status: (json['status'] as String?) ?? 'locked',
      words: words,
    );
  }
}

class BlendWordModel {
  final int id;
  final String wordText;
  final String? highlight;
  final String? imageUrl;
  final String? audioUrl;
  final List<String> tiles;

  const BlendWordModel({
    required this.id,
    required this.wordText,
    this.highlight,
    this.imageUrl,
    this.audioUrl,
    this.tiles = const [],
  });

  factory BlendWordModel.fromJson(Map<String, dynamic> json) {
    final rawTiles = json['tiles'];
    final tiles = <String>[];
    if (rawTiles is List) {
      for (final t in rawTiles) {
        tiles.add(t.toString());
      }
    }
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse('$rawId'.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return BlendWordModel(
      id: parsedId,
      wordText: (json['word'] as String?) ?? (json['word_text'] as String?) ?? '',
      highlight: json['highlight'] as String?,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      tiles: tiles,
    );
  }

  String highlightFor(String digraph) =>
      (highlight != null && highlight!.isNotEmpty) ? highlight! : digraph;
}

class BlendLessonDetailPayload {
  final BlendLessonModel lesson;
  final List<BlendWordModel> words;

  const BlendLessonDetailPayload({
    required this.lesson,
    required this.words,
  });

  factory BlendLessonDetailPayload.fromJson(Map<String, dynamic> json) {
    final lessonRaw = json['lesson'];
    final lesson = lessonRaw is Map<String, dynamic> ? BlendLessonModel.fromJson(lessonRaw) : BlendLessonModel(id: 0, code: '', title: '', soundLabel: '', iconUrl: null, audioUrl: null, exampleWordsPill: '', masteryPercent: 0, status: 'locked');
    final wordsRaw = json['words'];
    final words = <BlendWordModel>[];
    if (wordsRaw is List) {
      for (final e in wordsRaw) {
        if (e is Map<String, dynamic>) words.add(BlendWordModel.fromJson(e));
      }
    }
    return BlendLessonDetailPayload(lesson: lesson, words: words);
  }
}

class BlendCategoryModel {
  final int id;
  final String slug;
  final String title;
  final String tabFilterKey;
  final List<BlendLessonModel> lessons;

  const BlendCategoryModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.tabFilterKey,
    required this.lessons,
  });

  factory BlendCategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['lessons'];
    final lessons = <BlendLessonModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) lessons.add(BlendLessonModel.fromJson(e));
      }
    }
    return BlendCategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      tabFilterKey: (json['tab_filter_key'] as String?) ?? '',
      lessons: lessons,
    );
  }
}

class DailyQuestOption {
  final String code;
  final String label;

  const DailyQuestOption({required this.code, required this.label});

  factory DailyQuestOption.fromJson(Map<String, dynamic> json) {
    return DailyQuestOption(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
    );
  }
}

class DailyQuestModel {
  final int id;
  final String slug;
  final String prompt;
  final String maskedWord;
  final String targetWord;
  final List<DailyQuestOption> options;
  final int rewardCoins;

  const DailyQuestModel({
    required this.id,
    required this.slug,
    required this.prompt,
    required this.maskedWord,
    required this.targetWord,
    required this.options,
    required this.rewardCoins,
  });

  factory DailyQuestModel.fromJson(Map<String, dynamic> json) {
    final raw = json['options'];
    final opts = <DailyQuestOption>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) opts.add(DailyQuestOption.fromJson(e));
      }
    }
    return DailyQuestModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      slug: (json['slug'] as String?) ?? '',
      prompt: (json['prompt'] as String?) ?? '',
      maskedWord: (json['masked_word'] as String?) ?? '',
      targetWord: (json['target_word'] as String?) ?? '',
      options: opts,
      rewardCoins: json['reward_coins'] is int ? json['reward_coins'] as int : int.tryParse('${json['reward_coins']}') ?? 0,
    );
  }
}

class BlendForestHubPayload {
  final int coins;
  final String moduleCode;
  final String moduleTitle;
  final List<Map<String, dynamic>> masterySummary;
  final DailyQuestModel? dailyQuest;
  final List<BlendCategoryModel> categories;

  const BlendForestHubPayload({
    required this.coins,
    required this.moduleCode,
    required this.moduleTitle,
    required this.masterySummary,
    this.dailyQuest,
    required this.categories,
  });

  factory BlendForestHubPayload.fromJson(Map<String, dynamic> json) {
    final msRaw = json['mastery_summary'];
    final ms = <Map<String, dynamic>>[];
    if (msRaw is List) {
      for (final e in msRaw) {
        if (e is Map<String, dynamic>) ms.add(Map<String, dynamic>.from(e));
      }
    }
    final catRaw = json['categories'];
    final cats = <BlendCategoryModel>[];
    if (catRaw is List) {
      for (final e in catRaw) {
        if (e is Map<String, dynamic>) cats.add(BlendCategoryModel.fromJson(e));
      }
    }
    DailyQuestModel? dq;
    final dqRaw = json['daily_quest'];
    if (dqRaw is Map<String, dynamic>) dq = DailyQuestModel.fromJson(dqRaw);

    return BlendForestHubPayload(
      coins: json['coins'] is int ? json['coins'] as int : int.tryParse('${json['coins']}') ?? 0,
      moduleCode: (json['module_code'] as String?) ?? '',
      moduleTitle: (json['module_title'] as String?) ?? '',
      masterySummary: ms,
      dailyQuest: dq,
      categories: cats,
    );
  }

  BlendForestHubPayload copyWith({
    int? coins,
    DailyQuestModel? dailyQuest,
    bool clearDailyQuest = false,
  }) {
    return BlendForestHubPayload(
      coins: coins ?? this.coins,
      moduleCode: moduleCode,
      moduleTitle: moduleTitle,
      masterySummary: masterySummary,
      dailyQuest: clearDailyQuest ? null : (dailyQuest ?? this.dailyQuest),
      categories: categories,
    );
  }
}

