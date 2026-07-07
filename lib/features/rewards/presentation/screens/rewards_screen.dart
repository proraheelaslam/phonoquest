// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/standard_screen_header.dart';
import '../../data/rewards_models.dart';
import '../../data/rewards_repository.dart';
import '../../../../core/l10n/app_language_controller.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final _repo = RewardsRepository();
  RewardsHubPayload? _hub;
  bool _loading = true;
  String? _claimingCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (forceRefresh) ApiClient.clearRequestCache();
    setState(() => _loading = true);
    try {
      final hub = await _repo.fetchHub();
      if (!mounted) return;
      setState(() {
        _hub = hub;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claim(StudentReward reward) async {
    if (!reward.isClaimable || _claimingCode != null) return;
    setState(() => _claimingCode = reward.code);
    try {
      final result = await _repo.claimReward(reward.code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      await _load(forceRefresh: true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _claimingCode = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hub = _hub;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : hub == null
              ? Center(child: Text(context.tr('Could not load rewards.')))
              : RefreshIndicator(
                  onRefresh: () => _load(forceRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppScaffold.pageScrollPadding(context, top: 7, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StandardScreenHeader(title: context.tr('Rewards')),
                        SizedBox(height: 14),
                        _coinsCard(hub, textTheme),
                        SizedBox(height: 14),
                        Text(
                          hub.headline,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          hub.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                        if (hub.claimableCount > 0) ...[
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 191, 0, 0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${hub.claimableCount} reward${hub.claimableCount == 1 ? '' : 's'} ready to claim',
                              style: textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF8C6A1A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 14),
                        ...hub.rewards.map(
                          (reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _rewardCard(reward, textTheme),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _coinsCard(RewardsHubPayload hub, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19B6D2), Color(0xFF25A9B1)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 36),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hub.coins} Coins',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(context.tr('Earn more by completing quizzes and lessons.'),
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    color: Colors.white.withOpacity(.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(StudentReward reward, TextTheme textTheme) {
    final bgColor = reward.isClaimed
        ? const Color.fromRGBO(83, 200, 193, 0.18)
        : const Color.fromRGBO(255, 191, 0, 0.2);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bgColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  reward.description,
                  style: textTheme.bodyMedium?.copyWith(height: 1.25),
                ),
                SizedBox(height: 8),
                Text(
                  reward.progressLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (reward.progressPct.clamp(0, 100)) / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(.6),
                    color: reward.isClaimed
                        ? const Color(0xFF53C8C1)
                        : const Color(0xFF8C6A1A),
                  ),
                ),
                SizedBox(height: 10),
                if (reward.isClaimable)
                  TextButton(
                    onPressed: _claimingCode == reward.code ? null : () => _claim(reward),
                    child: Text(
                      _claimingCode == reward.code ? 'Claiming...' : 'Claim Reward (+${reward.rewardCoins})',
                      style: textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF8C6A1A),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else if (reward.isClaimed)
                  Text(
                    'Claimed',
                    style: textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF53C8C1),
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  Text(context.tr('Keep learning to unlock'),
                    style: textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF8C6A1A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 86,
            height: 86,
            child: Center(
              child: Image.asset(
                AppAssets.awardimage,
                width: 76,
                height: 76,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events_rounded,
                  size: 56,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
