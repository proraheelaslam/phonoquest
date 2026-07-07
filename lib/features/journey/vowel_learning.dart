import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/features/journey/data/vowel_learning_repository.dart';
import 'package:phonoquest_signup_flow/features/journey/data/vowel_learning_models.dart';
import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

class VowelLearningScreen extends StatefulWidget {
  const VowelLearningScreen({super.key});

  @override
  State<VowelLearningScreen> createState() => _VowelLearningScreeState();
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

class _VowelLearningScreeState extends State<VowelLearningScreen> {
  final VowelLearningRepository _repo = VowelLearningRepository();
  VowelHubPayload? _hub;
  bool _loadingHub = true;
  String? _hubError;

  static const _fallbackShortVowels = <_VowelCardData>[
    _VowelCardData(image: AppAssets.appleimage, title: 'Apple', subtitle: 'SHORT A'),
    _VowelCardData(image: AppAssets.waveimage, title: 'Wave', subtitle: 'SHORT E'),
    _VowelCardData(image: AppAssets.finimage, title: 'Fin', subtitle: 'SHORT I'),
    _VowelCardData(image: AppAssets.dogimage, title: 'Dog', subtitle: 'SHORT O'),
    _VowelCardData(image: AppAssets.bugimage, title: 'Bug', subtitle: 'SHORT U'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHub());
  }

  Future<void> _loadHub() async {
    setState(() {
      _loadingHub = true;
      _hubError = null;
    });
    try {
      final h = await _repo.fetchHub();
      if (!mounted) return;
      setState(() {
        _hub = h;
        _loadingHub = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hubError = e is Exception ? '$e' : 'Could not load hub';
        _loadingHub = false;
      });
    }
  }

  VowelCategoryModel? _categoryByKey(String key) {
    if (_hub == null) return null;
    for (final c in _hub!.categories) {
      if (c.tabFilterKey == key || c.slug == key) return c;
    }
    return null;
  }

  List<VowelLessonModel> _lessonsForCategory(String key) {
    return _categoryByKey(key)?.lessons ?? const [];
  }

  List<VowelLessonModel> _allLessons() {
    if (_hub == null) return const [];
    return _hub!.categories
        .where((c) => c.slug != 'sound_pairs' && c.tabFilterKey != 'sound_pairs')
        .expand((c) => c.lessons)
        .toList();
  }

  String _cardSubtitle(VowelLessonModel lesson) {
    final label = lesson.soundLabel.trim();
    if (label.isNotEmpty && label.length <= 24 && label == label.toUpperCase()) {
      return label;
    }
    final parts = lesson.code.split('_');
    if (parts.length >= 2) {
      final kind = parts[0].toLowerCase();
      if (kind == 'short' || kind == 'long') {
        return '${kind.toUpperCase()} ${parts[1].toUpperCase()}';
      }
    }
    if (label.isNotEmpty) return label;
    return lesson.title.toUpperCase();
  }

  String _assetForLesson(VowelLessonModel lesson) {
    final key = '${lesson.title} ${lesson.code}'.toLowerCase();
    if (key.contains('apple')) return AppAssets.appleimage;
    if (key.contains('wave')) return AppAssets.waveimage;
    if (key.contains('fin')) return AppAssets.finimage;
    if (key.contains('dog')) return AppAssets.dogimage;
    if (key.contains('bug')) return AppAssets.bugimage;
    if (key.contains('cake')) return AppAssets.redappleimage;
    if (key.contains('tree')) return AppAssets.sunimage;
    if (key.contains('kite')) return AppAssets.egleimage;
    if (key.contains('rose')) return AppAssets.sunnyimage;
    if (key.contains('mule')) return AppAssets.monkeyfaceimage;
    return AppAssets.appleimage;
  }

  _VowelCardData _lessonToCard(VowelLessonModel lesson) {
    return _VowelCardData(
      image: _assetForLesson(lesson),
      title: lesson.title,
      subtitle: _cardSubtitle(lesson),
      lesson: lesson,
    );
  }

  List<_VowelCardData> _cardsFromLessons(List<VowelLessonModel> lessons) {
    if (lessons.isEmpty) return const [];
    return lessons.map(_lessonToCard).toList();
  }

  List<_VowelCardData> _cardsForTab(String? categoryKey) {
    if (_hub == null) {
      if (categoryKey == null || categoryKey == 'short_vowels') {
        return _fallbackShortVowels;
      }
      return const [];
    }
    final lessons = categoryKey == null
        ? _allLessons()
        : _lessonsForCategory(categoryKey);
    final cards = _cardsFromLessons(lessons);
    if (cards.isNotEmpty) return cards;
    if (categoryKey == null || categoryKey == 'short_vowels') {
      return _fallbackShortVowels;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final allCards = _cardsForTab(null);
    final shortVowelCards = _cardsForTab('short_vowels');
    final longVowelCards = _cardsForTab('long_vowels');

    final tabSpecs = <_TabSpec>[
      _TabSpec(
        title: 'All',
        shortVowelHeading: 'All',
        builder: (spec) => _AllTab(
          textTheme: textTheme,
          shortVowels: allCards,
          shortVowelHeading: spec.shortVowelHeading ?? '',
        ),
      ),
      _TabSpec(
        title: context.tr('Short Vowels'),
        shortVowelHeading: 'Short Vowel',
        builder: (spec) => _ShortVowelsTab(
          textTheme: textTheme,
          shortVowels: shortVowelCards,
          heading: '',
        ),
      ),
      _TabSpec(
        title: context.tr('Long Vowels'),
        shortVowelHeading: 'Long Vowels',
        builder: (spec) => _ShortVowelsTab(
          textTheme: textTheme,
          shortVowels: longVowelCards,
          heading: '',
        ),
      ),
    ];

    // choose active lesson from hub if available
    final activeLesson = () {
      if (_hub != null && _hub!.categories.isNotEmpty) {
        for (final c in _hub!.categories) {
          if (c.lessons.isNotEmpty) {
            final inProgress = c.lessons.firstWhere((l) => l.status == 'in_progress', orElse: () => c.lessons.first);
            return inProgress;
          }
        }
      }
      return null;
    }();

    return DefaultTabController(
      length: tabSpecs.length,
      child: Scaffold(
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
                                Text(
                                  '${_hub?.coins ?? 20}',
                                  style: textTheme.labelLarge,
                                ),
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
                child: _loadingHub && _hub == null
                    ? Center(child: CircularProgressIndicator())
                    : _hubError != null && _hub == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _hubError!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: const Color(0xFF475467),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _loadHub,
                                    child: Text(context.tr('Retry'),
                                      style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
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
                               Text(context.tr('Vowel Learning'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(21, 21, 21, 1),
                                    ),
                                  ),
                                SizedBox(height: 6),
                                Text(context.tr('Master the building blocks of every\nword. Explore how tiny shifts in sound\ntransform "cap" into "cape".'),
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
                                AppAssets.vowelsimage,
                                fit: BoxFit.contain,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 14),
                      _ProgressCard(textTheme: textTheme),
                      SizedBox(height: 14),
                      _PillTabBar(tabs: tabSpecs),
                      SizedBox(height: 12),
                      _TabHeading(tabSpecs: tabSpecs),
                      SizedBox(height: 10),
                      _TabViewViewport(
                        child: TabBarView(
                          children: tabSpecs.map((t) => t.builder(t)).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ✅ TEAL SECTION (ALL SIDES ROUNDED)
                      Container(
                       margin: EdgeInsets.zero, // 👈 IMPORTANT (bottom radius visible)
                        decoration: BoxDecoration(
                          color: const Color(0xFF43C2BD),
                          borderRadius: BorderRadius.circular(12), // 👈 all sides
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('ACTIVE LESSON'),
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.black.withOpacity(.72),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .6,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                activeLesson?.title ?? "The Magic 'e' Principle",
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.black.withOpacity(.90),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                 activeLesson?.soundLabel ??
                                    "Watch how the silent 'e' at the end of a word stretches the vowel sound, making it \"say its name.\"",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.black.withOpacity(.70),
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 14),
                              Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                children: (activeLesson != null)
                                    ? [
                                        _WordSoundPill(word: activeLesson.exampleWordsPill.split('&').first.trim(), label: activeLesson.title),
                                        _WordSoundPill(word: activeLesson.exampleWordsPill.split('&').last.trim(), label: 'Example'),
                                      ]
                                    : [
                                        _WordSoundPill(word: 'cap', label: context.tr('SHORT /E/')),
                                        _WordSoundPill(word: 'cape', label: context.tr('LONG /E/')),
                                      ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                      SizedBox(height: 22),
                      _SectionTitle(title: context.tr('Vowel Teams')),
                      SizedBox(height: 8),
                      Text(context.tr('“When two vowels go walking, the first one does the talking!” Discover long vowel digraphs that work together.'),
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          color: const Color.fromRGBO(65, 71, 84, 1),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAECEF)),
                        ),
                        child: _DuoGrid(
                          items: [
                            _DuoData(
                              main: 'ai/ay',
                              sub: 'train, play',
                              color: Color(0xFF0B4DB8),
                            ),
                            _DuoData(
                              main: 'ee/ea',
                              sub: 'tree, leaf',
                              color: Color(0xFF0B7A3C),
                            ),
                            _DuoData(
                              main: 'oa/oe',
                              sub: 'boat, toe',
                              color: Color(0xFF8A6400),
                            ),
                            _DuoData(
                              main: 'ie/igh',
                              sub: 'pie, night',
                              color: Color(0xFF0B4DB8),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      _SectionTitle(title: context.tr('The Bossy R')),
                      SizedBox(height: 8),
                      Text(context.tr('When the letter R follows a vowel, it takes\ncontrol! It changes the vowel’s sound entirely.'),
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          color: const Color.fromRGBO(65, 71, 84, 1),
                        ),
                      ),
                      SizedBox(height: 12),
                      _ExamplePills(
                        rows: const [
                          _ExampleRowData(prefix: 'ar', example: 'like in star or car'),
                          _ExampleRowData(prefix: 'or', example: 'like in fork or corn'),
                          _ExampleRowData(prefix: 'er/ir/ur', example: 'like in fern, bird, surf'),
                        ],
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
      ),
    );
  }

}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12,right: 12,top: 14,bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
     SizedBox(
            width: 38,
            height: 38,
            child: Image.asset(
              AppAssets.wordimage,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Words Mastered'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(65, 71, 84, 1),
                    ),
                  ),
                SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '124 ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(26, 28, 28, 1),
                    ),
                  ),
                  TextSpan(
                    text: 'This month',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(113, 119, 134, 1),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
        ],
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
        final heading = spec.shortVowelHeading ?? spec.title;
        return Text(
          heading,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        );
      },
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
            labelPadding: const EdgeInsets.only(right: 10),

            tabs: List.generate(tabs.length, (index) {
              final isSelected = controller.index == index;

              return Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(248, 118, 146, 1) // selected
                        : Colors.white, // unselected
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index].title,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? const Color.fromRGBO(28, 28, 28, 1)
                            : const Color.fromRGBO(28, 28, 28, 1),
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
    required this.shortVowels,
    required this.shortVowelHeading,
  });

  final TextTheme textTheme;
  final List<_VowelCardData> shortVowels;
  final String shortVowelHeading;

  @override
  Widget build(BuildContext context) {
    return _ShortVowelsTab(
      textTheme: textTheme,
      shortVowels: shortVowels,
      heading: '',
    );
  }
}

class _ShortVowelsTab extends StatelessWidget {
  const _ShortVowelsTab({
    required this.textTheme,
    required this.shortVowels,
    required this.heading,
  });

  final TextTheme textTheme;
  final List<_VowelCardData> shortVowels;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading.isNotEmpty)
          Text(
            heading,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
        if (heading.isNotEmpty) SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 2;
              const mainAxisSpacing = 12.0;
              const crossAxisSpacing = 12.0;
              const childAspectRatio = 1.1;
              const maxVisibleItems = 5;

              final visibleCount =
                  shortVowels.length < maxVisibleItems ? shortVowels.length : maxVisibleItems;
              final visibleRows =
                  ((visibleCount + crossAxisCount - 1) / crossAxisCount).ceil();
              final itemWidth = (constraints.maxWidth - crossAxisSpacing) / crossAxisCount;
              final itemHeight = itemWidth / childAspectRatio;
              final gridHeight =
                  (visibleRows * itemHeight) + ((visibleRows - 1) * mainAxisSpacing);

              return SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: shortVowels.length > maxVisibleItems
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: shortVowels.length,
                  itemBuilder: (context, index) {
                    return _VowelCard(data: shortVowels[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VowelCardData {
  const _VowelCardData({
    required this.image,
    required this.title,
    required this.subtitle,
    this.lesson,
  });

  final String image; // 👈 emoji ki jagah image
  final String title;
  final String subtitle;
  final VowelLessonModel? lesson;
}

class _VowelCard extends StatelessWidget {
  const _VowelCard({required this.data});

  final _VowelCardData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.vowellearningdetail,
            arguments: data.lesson ?? data.title,
          );
        },
        child: Container(
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
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      data.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: const Color(0xFF98A2B3),
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



class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: const Color.fromRGBO(26, 28, 28, 1),
      ),
    );
  }
}

class _DuoData {
  const _DuoData({required this.main, required this.sub, required this.color});

  final String main;
  final String sub;
  final Color color;
}

class _DuoGrid extends StatelessWidget {
  const _DuoGrid({required this.items});

  final List<_DuoData> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Color(0xFFEAECEF), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                it.main,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: it.color,
                ),
              ),
              SizedBox(height: 10),
              Text(
                it.sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(65, 71, 84, 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExampleRowData {
  const _ExampleRowData({required this.prefix, required this.example});

  final String prefix;
  final String example;
}

class _ExamplePills extends StatelessWidget {
  const _ExamplePills({required this.rows});

  final List<_ExampleRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12), // 👈 thoda gap increase
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22, // 👈 MAIN HEIGHT INCREASE
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // 👈 smoother UI
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14, // 👈 badge height increase
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color.fromRGBO(245, 245, 245, 1), // 👈 border color
                          width: 1, // 👈 border thickness
                        ),
                      ),
                      child: Text(
                        r.prefix,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromRGBO(186, 26, 26, 1),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r.example,
                        style: GoogleFonts.lexend(
                          fontSize: 16, // 👈 text size increase
                          fontWeight: FontWeight.w400,
                          height: 1.4, // 👈 line spacing
                          color: const Color.fromRGBO(26, 28, 28, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
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
                AppAssets.silentimage,
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
                      child: Text(context.tr('Silent E Rule'),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                       color: const Color.fromRGBO(249, 220, 170, 1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(context.tr('PRO TIP'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color.fromRGBO(248, 118, 146, 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(context.tr("When an 'e' sits at the end of a CVC word, it jumps over the consonant to make the vowel long!"),
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: const Color(0xFF5A4A37),
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