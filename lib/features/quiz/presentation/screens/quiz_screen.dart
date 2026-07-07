// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/standard_screen_header.dart';
import '../../data/quiz_models.dart';
import '../../data/quiz_repository.dart';
import '../../../../core/l10n/app_language_controller.dart';

const _optionColors = <Color>[
  Color(0xFFF47495),
  Color(0xFF8A6400),
  Color(0xFF0B7A3C),
  Color(0xFF2F80ED),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _repo = QuizRepository();
  QuizHubPayload? _hub;
  bool _loading = true;
  int? _activeChallengeId;
  String? _selectedCode;
  bool _submitting = false;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (forceRefresh) ApiClient.clearRequestCache();
    setState(() {
      _loading = true;
      _resultMessage = null;
    });
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

  Future<void> _submit(QuizChallenge challenge) async {
    final code = _selectedCode;
    if (code == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await _repo.submitChallenge(
        exerciseId: challenge.id,
        selectedCode: code,
      );
      if (!mounted) return;
      setState(() {
        _resultMessage = result.correct
            ? 'Correct! +${result.rewardAppliedCoins} coins (total ${result.coinsTotal}).'
            : 'Not quite — try another challenge!';
        _submitting = false;
        _selectedCode = null;
        _activeChallengeId = null;
      });
      await _load(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resultMessage!)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
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
              ? Center(child: Text(context.tr('Could not load quiz challenges.')))
              : RefreshIndicator(
                  onRefresh: () => _load(forceRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppScaffold.pageScrollPadding(context, top: 7, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StandardScreenHeader(title: context.tr('Quiz')),
                        SizedBox(height: 14),
                        _summaryCard(hub, textTheme),
                        SizedBox(height: 14),
                        Text(context.tr('Review Challenges'),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          hub.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 14),
                        if (hub.challenges.isEmpty)
                          _emptyCard(textTheme)
                        else
                          ...hub.challenges.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _challengeCard(c, textTheme),
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _summaryCard(QuizHubPayload hub, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF43C2BD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hub.headline,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${hub.completedCount}/${hub.totalCount} completed',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(.72),
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${hub.coins} coins',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8C6A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.practiceimage, width: 52, height: 52, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _emptyCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Text(context.tr('Quiz challenges will appear as you unlock more phonics modules.'),
        style: textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
    );
  }

  Widget _challengeCard(QuizChallenge challenge, TextTheme textTheme) {
    final expanded = _activeChallengeId == challenge.id;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted
              ? const Color(0xFF53C8C1)
              : Colors.black.withOpacity(.06),
          width: challenge.isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: challenge.isCompleted
                ? null
                : () => setState(() {
                      _activeChallengeId = expanded ? null : challenge.id;
                      _selectedCode = null;
                      _resultMessage = null;
                    }),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          challenge.moduleLabel,
                          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                        if (challenge.maskedWord != null && challenge.maskedWord!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFF3ED),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              challenge.maskedWord!,
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF47495),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (challenge.isCompleted)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF53C8C1))
                      else
                        Icon(
                          expanded ? Icons.expand_less : Icons.play_circle_outline,
                          color: const Color(0xFFF47495),
                        ),
                      SizedBox(height: 6),
                      Text(
                        '+${challenge.rewardCoins}',
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.prompt,
                    style: textTheme.bodyMedium?.copyWith(height: 1.3),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < challenge.options.length; i++)
                        _optionChip(
                          challenge.options[i],
                          _optionColors[i % _optionColors.length],
                          _selectedCode == challenge.options[i].code,
                          () => setState(() => _selectedCode = challenge.options[i].code),
                        ),
                    ],
                  ),
                  SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedCode == null || _submitting
                          ? null
                          : () => _submit(challenge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF53C8C1),
                        foregroundColor: const Color(0xFF1A1C1C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _submitting ? 'CHECKING...' : 'SUBMIT ANSWER',
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionChip(QuizOption option, Color color, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? color.withOpacity(.25) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? color : Colors.black12, width: selected ? 2 : 1),
          ),
          child: Text(
            option.label,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
