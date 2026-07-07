import 'dart:convert';

class QuizHubPayload {
  final int coins;
  final String headline;
  final String subtitle;
  final int completedCount;
  final int totalCount;
  final List<QuizChallenge> challenges;

  const QuizHubPayload({
    required this.coins,
    required this.headline,
    required this.subtitle,
    required this.completedCount,
    required this.totalCount,
    required this.challenges,
  });

  factory QuizHubPayload.fromJson(Map<String, dynamic> json) {
    final challenges = json['challenges'];
    return QuizHubPayload(
      coins: _asInt(json['coins']),
      headline: (json['headline'] as String?) ?? 'Quiz & Review',
      subtitle: (json['subtitle'] as String?) ?? '',
      completedCount: _asInt(json['completed_count']),
      totalCount: _asInt(json['total_count']),
      challenges: challenges is List
          ? challenges.whereType<Map<String, dynamic>>().map(QuizChallenge.fromJson).toList()
          : const [],
    );
  }

  static QuizHubPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid quiz payload.');
    }
    return QuizHubPayload.fromJson(data);
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class QuizChallenge {
  final int id;
  final String slug;
  final String title;
  final String moduleLabel;
  final String prompt;
  final String? maskedWord;
  final int rewardCoins;
  final String status;
  final List<QuizOption> options;

  const QuizChallenge({
    required this.id,
    required this.slug,
    required this.title,
    required this.moduleLabel,
    required this.prompt,
    this.maskedWord,
    required this.rewardCoins,
    required this.status,
    required this.options,
  });

  bool get isCompleted => status == 'completed';

  factory QuizChallenge.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    return QuizChallenge(
      id: QuizHubPayload._asInt(json['id']),
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Quiz',
      moduleLabel: (json['module_label'] as String?) ?? 'Phonics Quiz',
      prompt: (json['prompt'] as String?) ?? '',
      maskedWord: json['masked_word'] as String?,
      rewardCoins: QuizHubPayload._asInt(json['reward_coins']),
      status: (json['status'] as String?) ?? 'available',
      options: options is List
          ? options.whereType<Map<String, dynamic>>().map(QuizOption.fromJson).toList()
          : const [],
    );
  }
}

class QuizOption {
  final String code;
  final String label;

  const QuizOption({required this.code, required this.label});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
    );
  }
}
