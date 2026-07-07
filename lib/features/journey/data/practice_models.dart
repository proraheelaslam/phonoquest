class ExerciseSubmitResult {
  final bool correct;
  final int rewardAppliedCoins;
  final int coinsTotal;

  const ExerciseSubmitResult({
    required this.correct,
    required this.rewardAppliedCoins,
    required this.coinsTotal,
  });

  factory ExerciseSubmitResult.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return ExerciseSubmitResult(
      correct: json['correct'] == true,
      rewardAppliedCoins: asInt(json['reward_applied_coins']),
      coinsTotal: asInt(json['coins_total']),
    );
  }
}
