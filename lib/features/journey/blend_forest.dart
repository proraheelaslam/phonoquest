// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_repository.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_sound_screen_args.dart';
import '../../core/l10n/app_language_controller.dart';

class BlendForestScreen extends StatefulWidget {
  const BlendForestScreen({super.key});

  @override
  State<BlendForestScreen> createState() => _BlendForestScreeState();
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

class _BlendForestScreeState extends State<BlendForestScreen> {
  final BlendForestRepository _repo = BlendForestRepository();
  BlendForestHubPayload? _hub;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final h = await _repo.fetchHub();
      if (!mounted) return;
      setState(() {
        _hub = h;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? '$e' : 'Something went wrong';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final defaultHBrothers = <_HBrotherCardData>[
      const _HBrotherCardData(
        image: AppAssets.shimage,
        digraph: 'SH',
        digraphColor: Color.fromRGBO(0, 89, 187, 1),
        soundType: 'QUIET SOUND',
        example: 'Ship & Shell',
      ),
      const _HBrotherCardData(
        image: AppAssets.chimage,
        digraph: 'CH',
        digraphColor: Color.fromRGBO(121, 89, 0, 1),
        soundType: 'CHOPPY SOUND',
        example: 'Chair & Chip',
      ),
      const _HBrotherCardData(
        image: AppAssets.thimage,
        digraph: 'TH',
        digraphColor: Color.fromRGBO(0, 107, 31, 1),
        soundType: 'QUIET SOUND',
        example: 'Moth & Think',
      ),
      const _HBrotherCardData(
        image: AppAssets.whimage,
        digraph: 'WH',
        digraphColor: Color.fromRGBO(219, 39, 119, 1),
        soundType: 'WISPY SOUND',
        example: 'Whale & Wheel',
      ),
      const _HBrotherCardData(
       image: AppAssets.phimage,
        digraph: 'PH',
        digraphColor: Color.fromRGBO(219, 108, 39, 1),
        soundType: 'WISPY SOUND',
        example: 'Phone & Graph',
      ),
      const _HBrotherCardData(
        image: AppAssets.phimage,
        digraph: 'TH',
        digraphColor: Color.fromRGBO(141, 39, 219, 1),
        soundType: 'QUIET SOUND',
        example: 'This & Them',
      ),
    ];

    final endingBlends = _hub != null
        ? _hub!.categories
            .firstWhere((c) => c.slug == 'ending_blends', orElse: () => BlendCategoryModel(id: 0, slug: '', title: '', tabFilterKey: '', lessons: []))
            .lessons
            .map((l) => _EndingBlendCardData(image: AppAssets.ndimage, blend: l.code, example: l.exampleWordsPill))
            .toList()
        : <_EndingBlendCardData>[
            const _EndingBlendCardData(image: AppAssets.ndimage, blend: 'nd', example: 'hand'),
            const _EndingBlendCardData(image: AppAssets.stimage, blend: 'st', example: 'fast'),
            const _EndingBlendCardData(image: AppAssets.ntimage, blend: 'nt', example: 'tent'),
            const _EndingBlendCardData(image: AppAssets.mpimage, blend: 'mp', example: 'camp'),
            const _EndingBlendCardData(image: AppAssets.nkimage, blend: 'nk', example: 'pink'),
            const _EndingBlendCardData(image: AppAssets.ngimage, blend: 'ng', example: 'sing'),
          ];

    final lBlends = _hub != null
        ? _hub!.categories
            .firstWhere((c) => c.slug == 'l_blends', orElse: () => BlendCategoryModel(id: 0, slug: '', title: '', tabFilterKey: '', lessons: []))
            .lessons
            .map((l) => _LBlendCardData(blend: l.code, examples: l.exampleWordsPill))
            .toList()
        : <_LBlendCardData>[
            const _LBlendCardData(blend: 'bl', examples: 'blue, blast'),
            const _LBlendCardData(blend: 'cl', examples: 'clap, clock'),
            const _LBlendCardData(blend: 'fl', examples: 'flag, fly'),
            const _LBlendCardData(blend: 'gl', examples: 'glad, glass'),
            const _LBlendCardData(blend: 'pl', examples: 'play, plum'),
            const _LBlendCardData(blend: 'sl', examples: 'slow, slip'),
          ];

    final tabSpecs = <_TabSpec>[
      _TabSpec(
        title: 'All',
        shortVowelHeading: 'All',
        builder: (spec) => _AllTab(
          textTheme: textTheme,
          shortVowelHeading: 'All',
          hBrothers: _hub != null
              ? _hub!.categories
                  .firstWhere((c) => c.slug == 'h_brothers', orElse: () => BlendCategoryModel(id: 0, slug: '', title: '', tabFilterKey: '', lessons: []))
                  .lessons
                  .map((l) => _HBrotherCardData(
                        id: l.id,
                        image: AppAssets.shimage,
                        digraph: l.code.toUpperCase(),
                        digraphColor: const Color.fromRGBO(0, 89, 187, 1),
                        soundType: l.soundLabel,
                        example: l.exampleWordsPill,
                        lessonAudioUrl: l.audioUrl,
                        words: l.words,
                      ))
                  .toList()
              : defaultHBrothers,
          endingBlends: endingBlends,
          lBlends: lBlends,
        ),
      ),
      _TabSpec(
        title: context.tr('H-Brothers'),
        shortVowelHeading: 'H-Brothers',
        builder: (spec) => _HBrothersTab(
          textTheme: textTheme,
          items: _hub != null
              ? _hub!.categories
                  .firstWhere((c) => c.slug == 'h_brothers', orElse: () => BlendCategoryModel(id: 0, slug: '', title: '', tabFilterKey: '', lessons: []))
                  .lessons
                  .map((l) => _HBrotherCardData(
                        id: l.id,
                        image: AppAssets.shimage,
                        digraph: l.code.toUpperCase(),
                        digraphColor: const Color.fromRGBO(0, 89, 187, 1),
                        soundType: l.soundLabel,
                        example: l.exampleWordsPill,
                        lessonAudioUrl: l.audioUrl,
                        words: l.words,
                      ))
                  .toList()
              : defaultHBrothers,
          heading: '',
        ),
      ),
      _TabSpec(
        title: context.tr('Ending Blends'),
        shortVowelHeading: 'Ending Blends',
        builder: (spec) => _EndingBlendsTab(
          textTheme: textTheme,
          items: endingBlends,
        ),
      ),
      _TabSpec(
        title: context.tr('L-Blends'),
        shortVowelHeading: 'L-Blends',
        builder: (spec) => _LBlendsTab(
          textTheme: textTheme,
          items: lBlends,
        ),
      ),
    ];

    return DefaultTabController(
      length: tabSpecs.length,
      child: Builder(
        builder: (context) {
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
                            onTap: () => AppRouter.navigateToDashboard(context),
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
                                    Text('20', style: textTheme.labelLarge),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
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
                                    Text(context.tr('Blend Forest'),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: const Color.fromRGBO(21, 21, 21, 1),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(context.tr("Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!."),
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
                                  AppAssets.journeyimage,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          _PillTabBar(tabs: tabSpecs),
                          SizedBox(height: 14),
                          _TabHeading(tabSpecs: tabSpecs),
                          SizedBox(height: 10),
                          AnimatedBuilder(
                            animation: DefaultTabController.of(context)!,
                            builder: (context, _) {
                              final controller = DefaultTabController.of(context)!;
                              final spec = tabSpecs[controller.index];
                              return spec.builder(spec);
                            },
                          ),
                          SizedBox(height: 20),
                          Text(context.tr('Ending Blends'),
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(28, 28, 28, 1),
                            ),
                          ),
                          SizedBox(height: 6),
                          _EndingBlendsTab(textTheme: textTheme, items: endingBlends),
                          SizedBox(height: 20),
                          Text(context.tr('L-Blends'),
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(28, 28, 28, 1),
                            ),
                          ),
                          SizedBox(height: 6),
                          _LBlendsTab(textTheme: textTheme, items: lBlends),
                          SizedBox(height: 16),
                          // ✅ TEAL SECTION (ALL SIDES ROUNDED)
                          if (_hub != null)
                            Container(
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
                                      child: Text(context.tr('Daily Quest:\nShell Search'),
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
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(context.tr('– – ELL'),
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
                                Text(context.tr('Select the correct blend to\ncomplete the word!'),
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    height: 1.25,
                                    color: const Color.fromRGBO(28, 28, 28, 1),
                                  ),
                                ),
                                SizedBox(height: 14),
                                if (_hub!.dailyQuest != null)
                                  Row(
                                    children: _hub!.dailyQuest!.options
                                        .map((o) => Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: _QuestOptionTile(
                                                  blend: o.code,
                                                  label: o.label,
                                                  color: const Color(0xFFF47495),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                              ],
                            ),
                            ),
                          if (_hub == null && _loading)
                            SizedBox(height: 12),

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
                                _MasteryRow(
                                  title: context.tr('SH Blends'),
                                  value: 0.80,
                                  color: const Color(0xFFF47495),
                                ),
                                SizedBox(height: 14),
                                _MasteryRow(
                                  title: context.tr('CH Blends'),
                                  value: 0.45,
                                  color: const Color(0xFF43C2BD),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 18),
                          _SilentERuleCard(textTheme: textTheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
  });

  final String blend;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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

class _AllTab extends StatelessWidget {
  const _AllTab({
    required this.textTheme,
    required this.shortVowelHeading,
    required this.hBrothers,
    required this.endingBlends,
    required this.lBlends,
  });

  final TextTheme textTheme;
  final String shortVowelHeading;
  final List<_HBrotherCardData> hBrothers;
  final List<_EndingBlendCardData> endingBlends;
  final List<_LBlendCardData> lBlends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HBrothersTab(textTheme: textTheme, items: hBrothers, heading: ''),
       // SizedBox(height: 18),
        Text(context.tr('Ending Blends'),
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
        SizedBox(height: 6),
        _EndingBlendsTab(textTheme: textTheme, items: endingBlends),
        SizedBox(height: 18),
        Text(context.tr('L-Blends'),
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
        SizedBox(height: 6),
        _LBlendsTab(textTheme: textTheme, items: lBlends),
      ],
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
        Text(context.tr('These are the core "complex sounds" where two\nconsonants combine to create a single, unique\nphoneme.'),
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            height: 1.25,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
        SizedBox(height: 14),
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
                    color: const Color(0xFF43C2BD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.shipimage,
                        width: 14,
                        height: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        data.example,
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromRGBO(28, 28, 28, 1),
                        ),
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

class _EndingBlendCardData {
  const _EndingBlendCardData({
    required this.image,
    required this.blend,
    required this.example,
  });

  final String image;
  final String blend;
  final String example;
}

class _EndingBlendsTab extends StatelessWidget {
  const _EndingBlendsTab({required this.textTheme, required this.items});

  final TextTheme textTheme;
  final List<_EndingBlendCardData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('These sounds appear at the end of words and require\n"blending" the two consonant sounds together\nsmoothly.'),
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            height: 1.25,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
        SizedBox(height: 14),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _EndingBlendCard(data: items[index]),
        ),
      ],
    );
  }
}

class _EndingBlendCard extends StatelessWidget {
  const _EndingBlendCard({required this.data});

  final _EndingBlendCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  data.image,
                  fit: BoxFit.contain,
                ),
              ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '-',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: const Color.fromRGBO(28, 28, 28, 1),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          data.blend,
                          style: GoogleFonts.lexend(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: const Color.fromRGBO(28, 28, 28, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    data.example,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LBlendCardData {
  const _LBlendCardData({required this.blend, required this.examples});

  final String blend;
  final String examples;
}

class _LBlendsTab extends StatelessWidget {
  const _LBlendsTab({required this.textTheme, required this.items});

  final TextTheme textTheme;
  final List<_LBlendCardData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr("Consonants followed by the letter 'L'."),
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            height: 1.25,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
        SizedBox(height: 14),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _LBlendCard(data: items[index]),
        ),
      ],
    );
  }
}

class _LBlendCard extends StatelessWidget {
  const _LBlendCard({required this.data});

  final _LBlendCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.blend,
            style: GoogleFonts.lexend(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color.fromRGBO(28, 28, 28, 1),
            ),
          ),
          SizedBox(height: 6),
          Text(
            data.examples,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SilentERuleCard extends StatelessWidget {
  const _SilentERuleCard({required this.textTheme});

  final TextTheme textTheme;

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
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      child: Text(context.tr('Go to WH Forest'),
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