import '../../../core/media/media_url.dart';

class PhonicsCardPayload {
  final List<PhonicsCard> cards;
  final PhonicsCardProgress? progress;

  const PhonicsCardPayload({
    required this.cards,
    this.progress,
  });

  factory PhonicsCardPayload.fromJson(Map<String, dynamic> json) {
    final cardsRaw = json['cards'];
    final cards = <PhonicsCard>[];
    if (cardsRaw is List) {
      for (final card in cardsRaw) {
        if (card is Map<String, dynamic>) {
          cards.add(PhonicsCard.fromJson(card));
        }
      }
    }

    PhonicsCardProgress? progress;
    final progressRaw = json['progress'];
    if (progressRaw is Map<String, dynamic>) {
      progress = PhonicsCardProgress.fromJson(progressRaw);
    }

    return PhonicsCardPayload(cards: cards, progress: progress);
  }
}

class PhonicsCardProgress {
  final int current;
  final int total;
  final String type;

  const PhonicsCardProgress({
    required this.current,
    required this.total,
    required this.type,
  });

  factory PhonicsCardProgress.fromJson(Map<String, dynamic> json) {
    return PhonicsCardProgress(
      current: json['current'] is int ? json['current'] as int : int.tryParse('${json['current']}') ?? 0,
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}') ?? 0,
      type: (json['type'] as String?) ?? '',
    );
  }
}

class PhonicsCard {
  final int letterId;
  final String uppercase;
  final String lowercase;
  final String pairLabel;
  final int sortOrder;
  final String status;
  final String phonicsAudioUrl;
  final PhonicsExampleWord exampleWord;

  const PhonicsCard({
    required this.letterId,
    required this.uppercase,
    required this.lowercase,
    required this.pairLabel,
    required this.sortOrder,
    required this.status,
    required this.phonicsAudioUrl,
    required this.exampleWord,
  });

  factory PhonicsCard.fromJson(Map<String, dynamic> json) {
    final exampleJson = json['example_word'];
    return PhonicsCard(
      letterId: json['letter_id'] is int ? json['letter_id'] as int : int.tryParse('${json['letter_id']}') ?? 0,
      uppercase: (json['uppercase'] as String?) ?? '',
      lowercase: (json['lowercase'] as String?) ?? '',
      pairLabel: (json['pair_label'] as String?) ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : int.tryParse('${json['sort_order']}') ?? 0,
      status: (json['status'] as String?) ?? '',
      phonicsAudioUrl: (json['phonics_audio_url'] as String?) ?? '',
      exampleWord: exampleJson is Map<String, dynamic>
          ? PhonicsExampleWord.fromJson(exampleJson)
          : const PhonicsExampleWord(),
    );
  }

  String get title => pairLabel;
  String get subtitle => exampleWord.wordText.isNotEmpty ? exampleWord.wordText : status;
  int get id => letterId;
  String get imageUrl => exampleWord.imageUrl;
  String get imageSmallUrl => exampleWord.imageSmallUrl.isNotEmpty ? exampleWord.imageSmallUrl : exampleWord.imageUrl;
  String get imageLargeUrl => exampleWord.imageLargeUrl.isNotEmpty ? exampleWord.imageLargeUrl : imageSmallUrl;

  String get displayListImageUrl => resolveMediaUrl(imageSmallUrl);

  String get displayDetailImageUrl => resolveMediaUrl(imageLargeUrl);

  String get displayAudioUrl => phonicsAudioUrl.isNotEmpty ? phonicsAudioUrl : exampleWord.audioUrl;
  String get displaySubtitle => subtitle;
}

class PhonicsExampleWord {
  final int id;
  final String wordText;
  final String imageUrl;
  final String imageSmallUrl;
  final String imageLargeUrl;
  final String audioUrl;

  const PhonicsExampleWord({
    this.id = 0,
    this.wordText = '',
    this.imageUrl = '',
    this.imageSmallUrl = '',
    this.imageLargeUrl = '',
    this.audioUrl = '',
  });

  factory PhonicsExampleWord.fromJson(Map<String, dynamic> json) {
    return PhonicsExampleWord(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      wordText: (json['word_text'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
      imageSmallUrl: (json['image_small_url'] as String?) ?? '',
      imageLargeUrl: (json['image_large_url'] as String?) ?? '',
      audioUrl: (json['audio_url'] as String?) ?? '',
    );
  }
}
