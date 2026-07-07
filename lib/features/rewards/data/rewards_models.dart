import 'dart:convert';

class RewardsHubPayload {
  final int coins;
  final String headline;
  final String subtitle;
  final int claimableCount;
  final List<StudentReward> rewards;

  const RewardsHubPayload({
    required this.coins,
    required this.headline,
    required this.subtitle,
    required this.claimableCount,
    required this.rewards,
  });

  factory RewardsHubPayload.fromJson(Map<String, dynamic> json) {
    final rewards = json['rewards'];
    return RewardsHubPayload(
      coins: _asInt(json['coins']),
      headline: (json['headline'] as String?) ?? 'Rewards',
      subtitle: (json['subtitle'] as String?) ?? '',
      claimableCount: _asInt(json['claimable_count']),
      rewards: rewards is List
          ? rewards.whereType<Map<String, dynamic>>().map(StudentReward.fromJson).toList()
          : const [],
    );
  }

  static RewardsHubPayload fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid rewards payload.');
    }
    return RewardsHubPayload.fromJson(data);
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class StudentReward {
  final String code;
  final String title;
  final String description;
  final String badgeLabel;
  final int rewardCoins;
  final int progressPct;
  final String status;
  final String progressLabel;

  const StudentReward({
    required this.code,
    required this.title,
    required this.description,
    required this.badgeLabel,
    required this.rewardCoins,
    required this.progressPct,
    required this.status,
    required this.progressLabel,
  });

  bool get isClaimable => status == 'claimable';
  bool get isClaimed => status == 'claimed';

  factory StudentReward.fromJson(Map<String, dynamic> json) {
    return StudentReward(
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      badgeLabel: (json['badge_label'] as String?) ?? '',
      rewardCoins: RewardsHubPayload._asInt(json['reward_coins']),
      progressPct: RewardsHubPayload._asInt(json['progress_pct']),
      status: (json['status'] as String?) ?? 'locked',
      progressLabel: (json['progress_label'] as String?) ?? '',
    );
  }
}

class ClaimRewardResult {
  final String rewardCode;
  final int rewardCoins;
  final int coinsTotal;
  final String message;

  const ClaimRewardResult({
    required this.rewardCode,
    required this.rewardCoins,
    required this.coinsTotal,
    required this.message,
  });

  factory ClaimRewardResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid claim reward payload.');
    }
    return ClaimRewardResult(
      rewardCode: (data['reward_code'] as String?) ?? '',
      rewardCoins: RewardsHubPayload._asInt(data['reward_coins']),
      coinsTotal: RewardsHubPayload._asInt(data['coins_total']),
      message: (data['message'] as String?) ?? (json['message'] as String?) ?? 'Reward claimed!',
    );
  }
}
