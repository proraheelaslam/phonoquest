class StreakBannerModel {
  final String headline;
  final String goalLabel;
  final int goalProgressPct;

  const StreakBannerModel({
    required this.headline,
    required this.goalLabel,
    required this.goalProgressPct,
  });

  factory StreakBannerModel.fromJson(Map<String, dynamic> json) {
    final pct = json['goal_progress_pct'];
    return StreakBannerModel(
      headline: (json['headline'] as String?) ?? '',
      goalLabel: (json['goal_label'] as String?) ?? '',
      goalProgressPct: pct is int ? pct : int.tryParse('$pct') ?? 0,
    );
  }
}

class MorningSongModel {
  final int id;
  final String title;
  final String? audioUrl;

  const MorningSongModel({
    required this.id,
    required this.title,
    this.audioUrl,
  });

  factory MorningSongModel.fromJson(Map<String, dynamic> json) {
    return MorningSongModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] as String?) ?? 'Play Morning Song',
      audioUrl: json['audio_url'] as String?,
    );
  }
}

class LoungeLetterModel {
  final int letterId;
  final String pairLabel;
  final String status;
  final String? phonicsAudioUrl;
  final int sortOrder;

  const LoungeLetterModel({
    required this.letterId,
    required this.pairLabel,
    required this.status,
    this.phonicsAudioUrl,
    required this.sortOrder,
  });

  factory LoungeLetterModel.fromJson(Map<String, dynamic> json) {
    final so = json['sort_order'];
    return LoungeLetterModel(
      letterId: json['letter_id'] is int ? json['letter_id'] as int : int.parse('${json['letter_id']}'),
      pairLabel: (json['pair_label'] as String?) ?? '${json['uppercase']}${json['lowercase']}',
      status: (json['status'] as String?) ?? 'locked',
      phonicsAudioUrl: json['phonics_audio_url'] as String?,
      sortOrder: so is int ? so : int.tryParse('$so') ?? 0,
    );
  }
}

class AlphabetLoungePayload {
  final int coins;
  final int streakDays;
  final StreakBannerModel streakBanner;
  final MorningSongModel? morningSong;
  final List<LoungeLetterModel> letters;

  const AlphabetLoungePayload({
    required this.coins,
    required this.streakDays,
    required this.streakBanner,
    this.morningSong,
    required this.letters,
  });

  factory AlphabetLoungePayload.fromJson(Map<String, dynamic> json) {
    final bannerRaw = json['streak_banner'];
    final banner = bannerRaw is Map<String, dynamic>
        ? StreakBannerModel.fromJson(bannerRaw)
        : const StreakBannerModel(headline: '', goalLabel: '', goalProgressPct: 0);

    MorningSongModel? morning;
    final m = json['morning_song'];
    if (m is Map<String, dynamic>) {
      morning = MorningSongModel.fromJson(m);
    }

    final lettersRaw = json['letters'];
    final letters = <LoungeLetterModel>[];
    if (lettersRaw is List) {
      for (final e in lettersRaw) {
        if (e is Map<String, dynamic>) {
          letters.add(LoungeLetterModel.fromJson(e));
        }
      }
      letters.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final coins = json['coins'];
    final streak = json['streak_days'];

    return AlphabetLoungePayload(
      coins: coins is int ? coins : int.tryParse('$coins') ?? 0,
      streakDays: streak is int ? streak : int.tryParse('$streak') ?? 0,
      streakBanner: banner,
      morningSong: morning,
      letters: letters,
    );
  }
}

/// `GET /alphabet/letters/{id}` — letter play screen payload.
class LetterWordClipModel {
  final int id;
  final String wordText;
  final String? imageUrl;
  final String? audioUrl;

  const LetterWordClipModel({
    required this.id,
    required this.wordText,
    this.imageUrl,
    this.audioUrl,
  });

  factory LetterWordClipModel.fromJson(Map<String, dynamic> json) {
    return LetterWordClipModel(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      wordText: (json['word_text'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
    );
  }
}

class LetterDetailPayload {
  final int letterId;
  final String pairLabel;
  final String? phonicsAudioUrl;
  final List<LetterWordClipModel> words;

  const LetterDetailPayload({
    required this.letterId,
    required this.pairLabel,
    this.phonicsAudioUrl,
    required this.words,
  });

  factory LetterDetailPayload.fromJson(Map<String, dynamic> json) {
    final wordsRaw = json['words'];
    final words = <LetterWordClipModel>[];
    if (wordsRaw is List) {
      for (final e in wordsRaw) {
        if (e is Map<String, dynamic>) {
          words.add(LetterWordClipModel.fromJson(e));
        }
      }
    }
    return LetterDetailPayload(
      letterId: json['letter_id'] is int ? json['letter_id'] as int : int.parse('${json['letter_id']}'),
      pairLabel: (json['pair_label'] as String?) ?? '',
      phonicsAudioUrl: json['phonics_audio_url'] as String?,
      words: words,
    );
  }
}

/// `GET /alphabet/letters/{id}/activity/find-sound` — letter sound match bubbles.
///
/// Submit (`find-word/submit`) expects JSON `{ "selected_word_id": <id> }` where
/// `<id>` is this bubble's [letterId] from the activity payload (same value as `letter_id` in GET).
class FindSoundBubbleModel {
  final int letterId;
  final String symbol;
  /// Optional word id when the activity provides a specific word clip id for this bubble.
  final int? wordId;

  const FindSoundBubbleModel({
    required this.letterId,
    required this.symbol,
    this.wordId,
  });

  /// Preferred id to send as `selected_word_id` when available; otherwise null.
  int? get preferredSelectedWordId => wordId;

  factory FindSoundBubbleModel.fromJson(Map<String, dynamic> json) {
    final lid = json['letter_id'];
    final widRaw = json['word_id'] ?? json['word_clip_id'] ?? json['selected_word_id'];
    int? wid;
    if (widRaw != null) {
      wid = widRaw is int ? widRaw : int.tryParse('$widRaw');
    }
    return FindSoundBubbleModel(
      letterId: lid is int ? lid : int.parse('$lid'),
      symbol: (json['symbol'] as String?) ?? '',
      wordId: wid,
    );
  }
}

class FindSoundActivityPayload {
  final String prompt;
  final int targetLetterId;
  final String targetUppercase;
  final List<FindSoundBubbleModel> bubbles;

  const FindSoundActivityPayload({
    required this.prompt,
    required this.targetLetterId,
    required this.targetUppercase,
    required this.bubbles,
  });

  factory FindSoundActivityPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['bubbles'];
    final bubbles = <FindSoundBubbleModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          bubbles.add(FindSoundBubbleModel.fromJson(e));
        }
      }
    }
    final tid = json['target_letter_id'];
    return FindSoundActivityPayload(
      prompt: (json['prompt'] as String?) ?? '',
      targetLetterId: tid is int ? tid : int.tryParse('$tid') ?? 0,
      targetUppercase: (json['target_uppercase'] as String?) ?? '',
      bubbles: bubbles,
    );
  }
}

class FindSoundSubmitData {
  final bool correct;
  final int? selectedLetterId;
  final int? correctLetterId;
  final int rewardAppliedCoins;
  final int coinsTotal;
  final String letterProgress;

  const FindSoundSubmitData({
    required this.correct,
    this.selectedLetterId,
    this.correctLetterId,
    required this.rewardAppliedCoins,
    required this.coinsTotal,
    required this.letterProgress,
  });

  factory FindSoundSubmitData.fromJson(Map<String, dynamic> json) {
    final sel = json['selected_letter_id'] ?? json['letter_id'] ?? json['selected_word_id'];
    final cor = json['correct_letter_id'] ?? json['correct_word_id'];
    final coins = json['coins_total'];
    final reward = json['reward_applied_coins'];
    final correctRaw = json['correct'];
    final correct = correctRaw == true ||
        correctRaw == 1 ||
        (correctRaw is String && const {'true', '1', 'yes'}.contains(correctRaw.trim().toLowerCase()));
    return FindSoundSubmitData(
      correct: correct,
      selectedLetterId: sel is int ? sel : int.tryParse('$sel'),
      correctLetterId: cor is int ? cor : int.tryParse('$cor'),
      rewardAppliedCoins: reward is int ? reward : int.tryParse('$reward') ?? 0,
      coinsTotal: coins is int ? coins : int.tryParse('$coins') ?? 0,
      letterProgress: (json['letter_progress'] as String?) ?? '',
    );
  }
}

class MasteredLettersPayload {
  const MasteredLettersPayload({
    required this.letterIds,
    required this.labels,
  });

  final List<int> letterIds;
  final List<String> labels;

  factory MasteredLettersPayload.fromJson(Map<String, dynamic> json) {
    final idsRaw = json['mastered_letter_ids'];
    final labelsRaw = json['labels'];
    final ids = idsRaw is List
        ? idsRaw.map((e) => e is int ? e : int.tryParse('$e') ?? 0).where((id) => id > 0).toList()
        : <int>[];
    final labels = labelsRaw is List
        ? labelsRaw.map((e) => '$e'.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];
    return MasteredLettersPayload(letterIds: ids, labels: labels);
  }
}
