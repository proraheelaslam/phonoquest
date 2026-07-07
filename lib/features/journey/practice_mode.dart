// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import 'data/blend_forest_models.dart';
import 'data/blend_sound_screen_args.dart';
import 'data/practice_repository.dart';
import '../../core/l10n/app_language_controller.dart';

const _questOptionColors = <Color>[
  Color(0xFFF47495),
  Color(0xFF8A6400),
  Color(0xFF0B7A3C),
  Color(0xFF2F80ED),
];

Color _digraphColor(String code) {
  switch (code.toUpperCase()) {
    case 'CH':
      return const Color.fromRGBO(121, 89, 0, 1);
    case 'TH':
      return const Color.fromRGBO(0, 107, 31, 1);
    case 'WH':
      return const Color.fromRGBO(219, 39, 119, 1);
    case 'PH':
      return const Color.fromRGBO(219, 108, 39, 1);
    default:
      return const Color.fromRGBO(0, 89, 187, 1);
  }
}

String? _digraphAsset(String code) {
  switch (code.toUpperCase()) {
    case 'SH':
      return AppAssets.quietsoundimage;
    case 'CH':
      return AppAssets.choppysoundimage;
    case 'TH':
      return AppAssets.alarmsoundimage;
    case 'WH':
      return AppAssets.wispysoundimage;
    default:
      return AppAssets.quietsoundimage;
  }
}

class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreeState();
}

class _WordSoundPill extends StatelessWidget {
  const _WordSoundPill({required this.word, required this.label});

  final String word;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBFF3ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              word,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1,
                color: const Color(0xFFF47495),
              ),
            ),
            SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF1C1C1C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabViewViewport extends StatelessWidget {
  const _TabViewViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const mainAxisSpacing = 12.0;
        const crossAxisSpacing = 12.0;
        const childAspectRatio = 1.1;
        const maxVisibleItems = 5;

        final visibleRows = ((maxVisibleItems + crossAxisCount - 1) / crossAxisCount).ceil();
        final itemWidth = (constraints.maxWidth - crossAxisSpacing) / crossAxisCount;
        final itemHeight = itemWidth / childAspectRatio;
        final gridHeight =
            (visibleRows * itemHeight) + ((visibleRows - 1) * mainAxisSpacing);

        return SizedBox(height: gridHeight, child: child);
      },
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.title,
    required this.builder,
    this.shortVowelHeading,
  });

  final String title;
  final Widget Function(_TabSpec spec) builder;
  final String? shortVowelHeading;
}

class _PracticeModeScreeState extends State<PracticeModeScreen> {
  final PracticeRepository _repo = PracticeRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _questSectionKey = GlobalKey();

  BlendForestHubPayload? _hub;
  bool _loading = true;
  String? _error;
  int _coins = 0;
  String? _selectedOptionCode;
  bool _submitting = false;
  bool? _lastAnswerCorrect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedOptionCode = null;
      _lastAnswerCorrect = null;
    });
    try {
      final hub = await _repo.fetchHub();
      if (!mounted) return;
      setState(() {
        _hub = hub;
        _coins = hub.coins;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Could not load Practice Mode.';
        _loading = false;
      });
    }
  }

  List<_HBrotherCardData> _hBrotherCards() {
    final lessons = _hub?.categories
            .where((c) => c.slug == 'h_brothers')
            .expand((c) => c.lessons)
            .toList() ??
        const <BlendLessonModel>[];

    if (lessons.isEmpty) {
      return const [
        _HBrotherCardData(
          image: AppAssets.quietsoundimage,
          digraph: 'SH',
          digraphColor: Color.fromRGBO(0, 89, 187, 1),
          soundType: 'QUIET SOUND',
          example: 'START',
        ),
        _HBrotherCardData(
          image: AppAssets.choppysoundimage,
          digraph: 'CH',
          digraphColor: Color.fromRGBO(121, 89, 0, 1),
          soundType: 'CHOPPY SOUND',
          example: 'START',
        ),
        _HBrotherCardData(
          image: AppAssets.alarmsoundimage,
          digraph: 'TH',
          digraphColor: Color.fromRGBO(0, 107, 31, 1),
          soundType: 'QUIET SOUND',
          example: 'START',
        ),
        _HBrotherCardData(
          image: AppAssets.wispysoundimage,
          digraph: 'WH',
          digraphColor: Color.fromRGBO(219, 39, 119, 1),
          soundType: 'WISPY SOUND',
          example: 'START',
        ),
      ];
    }

    return lessons
        .map(
          (l) => _HBrotherCardData(
            id: l.id,
            image: _digraphAsset(l.code),
            digraph: l.code.toUpperCase(),
            digraphColor: _digraphColor(l.code),
            soundType: l.soundLabel,
            example: l.exampleWordsPill.isNotEmpty ? l.exampleWordsPill : 'START',
            lessonAudioUrl: l.audioUrl,
            words: l.words,
          ),
        )
        .toList();
  }

  List<Widget> _masteryRows() {
    final summary = _hub?.masterySummary ?? const [];
    if (summary.isEmpty) {
      return [
        _MasteryRow(title: context.tr('SH Blends'), value: 0.0, color: const Color(0xFFF47495)),
        const SizedBox(height: 14),
        _MasteryRow(title: context.tr('CH Blends'), value: 0.0, color: const Color(0xFF43C2BD)),
      ];
    }

    final colors = const [Color(0xFFF47495), Color(0xFF43C2BD), Color(0xFF0B7A3C), Color(0xFF2F80ED)];
    final rows = <Widget>[];
    for (var i = 0; i < summary.length && i < 4; i++) {
      final item = summary[i];
      final pct = item['avg_mastery_pct'];
      final value = (pct is int ? pct : int.tryParse('$pct') ?? 0) / 100.0;
      if (i > 0) rows.add(SizedBox(height: 14));
      rows.add(
        _MasteryRow(
          title: (item['title'] as String?) ?? 'Mastery',
          value: value,
          color: colors[i % colors.length],
        ),
      );
    }
    return rows;
  }

  void _scrollToQuest() {
    final ctx = _questSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * 0.55,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitQuest(String code) async {
    final quest = _hub?.dailyQuest;
    if (quest == null || _submitting) return;

    setState(() {
      _selectedOptionCode = code;
      _submitting = true;
      _lastAnswerCorrect = null;
    });

    try {
      final result = await _repo.submitExercise(
        exerciseId: quest.id,
        selectedCode: code,
      );
      if (!mounted) return;
      setState(() {
        _coins = result.coinsTotal;
        _lastAnswerCorrect = result.correct;
        _submitting = false;
      });
      final message = result.correct
          ? 'Correct! +${result.rewardAppliedCoins} coins'
          : 'Try again — pick another blend!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      if (result.correct) {
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : 'Could not submit answer.',
          ),
        ),
      );
    }
  }

  String _questTitle(DailyQuestModel? quest) {
    if (quest == null) return 'Daily Quest';
    if (quest.slug == 'shell_search_daily') return 'Daily Quest:\nShell Search';
    return 'Daily Quest';
  }

  String _maskedWordDisplay(DailyQuestModel? quest) {
    final masked = quest?.maskedWord ?? '';
    if (masked.isEmpty) return '– –';
    return masked.replaceAll('_', '–');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hBrothers = _hBrotherCards();
    final quest = _hub?.dailyQuest;

    if (_loading && _hub == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _hub == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 12),
                TextButton(onPressed: _load, child: Text(context.tr('Retry'))),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 3),
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  AppAssets.backimage,
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(247, 205, 135, 1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      AppAssets.starimage,
                                      width: 10,
                                      height: 10,
                                    ),
                                    SizedBox(width: 6),
                                    Text('$_coins', style: textTheme.labelLarge),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.tr('Practice Mode'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(21, 21, 21, 1),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    quest != null
                                        ? 'Daily quest loaded — pick a blend and earn coins!'
                                        : 'Practice your sounds and build words every day.',
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w200,
                                      height: 1.25,
                                      color: const Color.fromRGBO(21, 21, 21, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12),
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: Image.asset(
                                AppAssets.practiceimage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),

                            ],
                          ),

                        SizedBox(height: 10),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ✅ TEAL SECTION (ALL SIDES ROUNDED)
                     Container(
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0xFF43C2BD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                                child: Stack(
                                  children: [
                                    /// 🔹 MAIN CONTENT
                                    Padding(
                                      padding: const EdgeInsets.only(right: 64),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(context.tr('Ready to play?'),
                                            style: textTheme.headlineSmall?.copyWith(
                                              color: Colors.black.withOpacity(.90),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          SizedBox(height: 6),

                                          Text(context.tr("Let's practice your sounds and build some words! Every game you play makes your brain stronger."),
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: Colors.black.withOpacity(.70),
                                              height: 1.0,
                                            ),
                                          ),

                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),

                                    /// 🔹 TOP RIGHT FLOATING IMAGE (FIXED POSITION)
                                    Positioned(
                                      top: 5,
                                      right: 0,

                                      child: Image.asset(
                                        AppAssets.readyimage,
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      // ✅ RESUME BUTTON (UNCHANGED)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), // left/right/bottom only
                          child: Material(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              onTap: quest != null ? _scrollToQuest : null,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only( // 👈 FIXED
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(.06),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                   AppAssets.playimage, // apni image ka path
                                    height: 24,
                                    width: 24,

                                  ),
                                    SizedBox(width: 8),
                                    Text(context.tr('Start Daily Quest'),
                                      style: textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFFF47495),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: .8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),

                          SizedBox(height: 14),
                          _HBrothersTab(
                            textTheme: textTheme,
                            items: hBrothers,
                            heading: '',
                          ),
                          SizedBox(height: 20),

                          if (quest != null)
                            Container(
                              key: _questSectionKey,
                              decoration: BoxDecoration(
                                color: const Color(0xFF43C2BD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _questTitle(quest),
                                          style: GoogleFonts.lexend(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                            color: const Color.fromRGBO(28, 28, 28, 1),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        height: 44,
                                        padding: const EdgeInsets.symmetric(horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _maskedWordDisplay(quest),
                                          style: GoogleFonts.lexend(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFF47495),
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  if (quest.rewardCoins > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3D6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Earn ${quest.rewardCoins} coins',
                                        style: GoogleFonts.lexend(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF8A6400),
                                        ),
                                      ),
                                    ),
                                  if (quest.rewardCoins > 0) SizedBox(height: 8),
                                  Text(
                                    quest.prompt.isNotEmpty
                                        ? quest.prompt
                                        : 'Select the correct blend to\ncomplete the word!',
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      height: 1.25,
                                      color: const Color.fromRGBO(28, 28, 28, 1),
                                    ),
                                  ),
                                  if (_lastAnswerCorrect != null) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      _lastAnswerCorrect!
                                          ? 'Great job! Coins added to your wallet.'
                                          : 'Not quite — try another blend.',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _lastAnswerCorrect!
                                            ? const Color(0xFF0B7A3C)
                                            : const Color(0xFFB42318),
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 14),
                                  Row(
                                    children: [
                                      for (var i = 0; i < quest.options.length; i++) ...[
                                        if (i > 0) SizedBox(width: 12),
                                        Expanded(
                                          child: _QuestOptionTile(
                                            blend: quest.options[i].code,
                                            label: quest.options[i].label,
                                            color: _questOptionColors[i % _questOptionColors.length],
                                            isSelected: _selectedOptionCode == quest.options[i].code,
                                            isDisabled: _submitting,
                                            onTap: () => _submitQuest(quest.options[i].code),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (_submitting)
                                    Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Container(
                              key: _questSectionKey,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(context.tr('Daily quest will appear after your teacher assigns practice or you unlock Blend Forest.'),
                                style: GoogleFonts.lexend(fontSize: 13),
                              ),
                            ),

                          SizedBox(height: 0),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(26, 14, 26, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                   SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Image.asset(
                                        AppAssets.forestimage,
                                        fit: BoxFit.contain,

                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(context.tr('Forest Mastery'),
                                      style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color.fromRGBO(28, 28, 28, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                ..._masteryRows(),
                              ],
                            ),
                          ),

                          SizedBox(height: 18),
                          _SilentERuleCard(
                            textTheme: textTheme,
                            onGoToForest: () => Navigator.pushNamed(context, AppRouter.blendforest),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

}



class _TabHeading extends StatelessWidget {
  const _TabHeading({required this.tabSpecs});

  final List<_TabSpec> tabSpecs;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, _) {
        final i = controller.index;
        final spec = tabSpecs[i];
        final heading = spec.title;
        return Text(
          heading,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        );
      },
    );
  }
}

class _QuestOptionTile extends StatelessWidget {
  const _QuestOptionTile({
    required this.blend,
    required this.label,
    required this.color,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
  });

  final String blend;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: color, width: 2) : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                blend,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: const Color.fromRGBO(28, 28, 28, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.title, required this.value, required this.color});

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromRGBO(28, 28, 28, 1),
                ),
              ),
            ),
            Text(
              '$pct%',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(28, 28, 28, 1),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: const Color(0xFFF2F4F7),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.tabs});

  final List<_TabSpec> tabs;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: controller!,
        builder: (context, _) {
          return TabBar(
            controller: controller,
            isScrollable: true,
            indicator: const BoxDecoration(), // remove default indicator
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.only(right: 12),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),

            tabs: List.generate(tabs.length, (index) {
              final isSelected = controller.index == index;

              return Tab(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(248, 118, 146, 1) // selected
                        : Colors.white, // unselected
                    border: isSelected
                        ? null
                        : Border.all(
                            color: const Color(0xFFEAECEF),
                            width: 1,
                          ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index].title,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}


//H-Brothers
class _HBrothersTab extends StatelessWidget {
  const _HBrothersTab({
    required this.textTheme,
    required this.items,
    required this.heading,
  });

  final TextTheme textTheme;
  final List<_HBrotherCardData> items;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _HBrotherCard(data: items[index]),
          ),
      ],
    );
  }
}

class _HBrotherCardData {
  const _HBrotherCardData({
    this.id,
    this.image,
    required this.digraph,
    required this.digraphColor,
    required this.soundType,
    required this.example,
    this.lessonAudioUrl,
    this.words = const [],
  });

  final int? id;
  final String? image;
  final String digraph;
  final Color digraphColor;
  final String soundType;
  final String example;
  final String? lessonAudioUrl;
  final List<BlendWordModel> words;
}

class _HBrotherCard extends StatelessWidget {
  const _HBrotherCard({required this.data});

  final _HBrotherCardData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final Object arg = data.id != null
              ? BlendSoundScreenArgs(
                  lessonId: data.id!,
                  digraph: data.digraph,
                  lessonAudioUrl: data.lessonAudioUrl,
                  words: data.words,
                )
              : data.digraph;
          Navigator.pushNamed(
            context,
            AppRouter.blendforestdsound,
            arguments: arg,
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: data.image != null
                      ? Image.asset(
                          data.image!,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(height: 10),
                Text(
                  data.digraph,
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: data.digraphColor,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  data.soundType,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(232, 125, 147, 1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.example,
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromRGBO(28, 28, 28, 1),
                        ),
                      ),
                      SizedBox(width: 6),
                      Image.asset(
                        AppAssets.starticonimage,
                        width: 5,
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








class _SilentERuleCard extends StatelessWidget {
  const _SilentERuleCard({
    required this.textTheme,
    required this.onGoToForest,
  });

  final TextTheme textTheme;
  final VoidCallback onGoToForest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 203, 124, 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Image.asset(
                AppAssets.tamerimage,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(context.tr('Unlock Whale Tamer'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10),
                Text(context.tr('Complete 3 WH exercises to earn this sticker!'),
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: const Color(0xFF5A4A37),
                  ),
                ),
                SizedBox(height: 14),
                Material(
                  color: const Color(0xFFF47495),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onGoToForest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      child: Text(context.tr('Go to Blend Forest'),
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}