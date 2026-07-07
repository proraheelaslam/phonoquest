class VowelLessonModel {
  final int id;
  final String code;
  final String title;
  final String soundLabel;
  final String? iconUrl;
  final String? audioUrl;
  final String exampleWordsPill;
  final int masteryPercent;
  final String status;

  const VowelLessonModel({
    required this.id,
    required this.code,
    required this.title,
    required this.soundLabel,
    this.iconUrl,
    this.audioUrl,
    required this.exampleWordsPill,
    required this.masteryPercent,
    required this.status,
  });

  factory VowelLessonModel.fromJson(Map<String, dynamic> json) {
    return VowelLessonModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      soundLabel: (json['sound_label'] as String?) ?? '',
      iconUrl: json['icon_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      exampleWordsPill: (json['example_words_pill'] as String?) ?? '',
      masteryPercent: json['mastery_percent'] is int ? json['mastery_percent'] as int : int.tryParse('${json['mastery_percent']}') ?? 0,
      status: (json['status'] as String?) ?? 'locked',
    );
  }
}

class VowelCategoryModel {
  final int id;
  final String slug;
  final String title;
  final String tabFilterKey;
  final List<VowelLessonModel> lessons;

  const VowelCategoryModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.tabFilterKey,
    required this.lessons,
  });

  factory VowelCategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['lessons'];
    final lessons = <VowelLessonModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) lessons.add(VowelLessonModel.fromJson(e));
      }
    }
    return VowelCategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      tabFilterKey: (json['tab_filter_key'] as String?) ?? '',
      lessons: lessons,
    );
  }
}

class VowelHubPayload {
  final int coins;
  final String moduleCode;
  final String moduleTitle;
  final List<Map<String, dynamic>> masterySummary;
  final dynamic dailyQuest;
  final List<VowelCategoryModel> categories;

  const VowelHubPayload({
    required this.coins,
    required this.moduleCode,
    required this.moduleTitle,
    required this.masterySummary,
    this.dailyQuest,
    required this.categories,
  });

  factory VowelHubPayload.fromJson(Map<String, dynamic> json) {
    final msRaw = json['mastery_summary'];
    final ms = <Map<String, dynamic>>[];
    if (msRaw is List) {
      for (final e in msRaw) {
        if (e is Map<String, dynamic>) ms.add(Map<String, dynamic>.from(e));
      }
    }
    final catRaw = json['categories'];
    final cats = <VowelCategoryModel>[];
    if (catRaw is List) {
      for (final e in catRaw) {
        if (e is Map<String, dynamic>) cats.add(VowelCategoryModel.fromJson(e));
      }
    }
    return VowelHubPayload(
      coins: json['coins'] is int ? json['coins'] as int : int.tryParse('${json['coins']}') ?? 0,
      moduleCode: (json['module_code'] as String?) ?? '',
      moduleTitle: (json['module_title'] as String?) ?? '',
      masterySummary: ms,
      dailyQuest: json['daily_quest'],
      categories: cats,
    );
  }
}

class WordBuilderRandomOut {
  WordBuilderRandomOut({
    required this.wordId,
    required this.lessonId,
    required this.rulePill,
    required this.targetBlendCode,
    required this.instruction,
    required this.targetWordDisplay,
    required this.slotCount,
    required this.vowelSlotIndex,
    this.magicESlotIndex,
    required this.tilePool,
    this.imageUrl,
    this.wordAudioUrl,
    this.lessonAudioUrl,
  });

  final int wordId;
  final int lessonId;
  final String rulePill;
  final String targetBlendCode;
  final String instruction;
  final String targetWordDisplay;
  final int slotCount;
  final int vowelSlotIndex;
  final int? magicESlotIndex;
  final List<String> tilePool;
  final String? imageUrl;
  final String? wordAudioUrl;
  final String? lessonAudioUrl;

  factory WordBuilderRandomOut.fromJson(Map<String, dynamic> json) {
    final rawTilePool = json['tile_pool'];
    final tilePool = <String>[];
    if (rawTilePool is List) {
      for (final item in rawTilePool) {
        if (item is String) {
          tilePool.add(item);
        } else {
          tilePool.add('$item');
        }
      }
    }

    return WordBuilderRandomOut(
      wordId: json['word_id'] is int ? json['word_id'] as int : int.tryParse('${json['word_id']}') ?? 0,
      lessonId: json['lesson_id'] is int ? json['lesson_id'] as int : int.tryParse('${json['lesson_id']}') ?? 0,
      rulePill: (json['rule_pill'] as String?) ?? '',
      targetBlendCode: (json['target_blend_code'] as String?) ?? '',
      instruction: (json['instruction'] as String?) ?? '',
      targetWordDisplay: (json['target_word_display'] as String?) ?? '',
      slotCount: json['slot_count'] is int ? json['slot_count'] as int : int.tryParse('${json['slot_count']}') ?? 0,
      vowelSlotIndex: json['vowel_slot_index'] is int ? json['vowel_slot_index'] as int : int.tryParse('${json['vowel_slot_index']}') ?? 0,
      magicESlotIndex: json['magic_e_slot_index'] is int ? json['magic_e_slot_index'] as int : null,
      tilePool: tilePool,
      imageUrl: json['image_url'] as String?,
      wordAudioUrl: json['word_audio_url'] as String?,
      lessonAudioUrl: json['lesson_audio_url'] as String?,
    );
  }
}

class WordBuilderSubmitResultOut {
  WordBuilderSubmitResultOut({
    required this.correct,
    required this.mode,
    required this.wordId,
    required this.targetWord,
    required this.rewardAppliedCoins,
    required this.coinsTotal,
  });

  final bool correct;
  final String mode;
  final int wordId;
  final String targetWord;
  final int rewardAppliedCoins;
  final int coinsTotal;

  factory WordBuilderSubmitResultOut.fromJson(Map<String, dynamic> json) {
    return WordBuilderSubmitResultOut(
      correct: json['correct'] is bool ? json['correct'] as bool : '${json['correct']}'.toLowerCase() == 'true',
      mode: (json['mode'] as String?) ?? '',
      wordId: json['word_id'] is int ? json['word_id'] as int : int.tryParse('${json['word_id']}') ?? 0,
      targetWord: (json['target_word'] as String?) ?? '',
      rewardAppliedCoins: json['reward_applied_coins'] is int ? json['reward_applied_coins'] as int : int.tryParse('${json['reward_applied_coins']}') ?? 0,
      coinsTotal: json['coins_total'] is int ? json['coins_total'] as int : int.tryParse('${json['coins_total']}') ?? 0,
    );
  }
}

