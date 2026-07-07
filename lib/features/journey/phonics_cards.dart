// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/features/journey/phonics_cards_detail.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../core/router/app_router.dart';
import 'data/phonics_cards_models.dart';
import 'data/phonics_cards_repository.dart';
import '../../core/l10n/app_language_controller.dart';

class PhnoicsCardsScreen extends StatefulWidget {
  const PhnoicsCardsScreen({super.key});

  @override
  State<PhnoicsCardsScreen> createState() => _PhnoicsCardsScreenState();
}

class _PhnoicsCardsScreenState extends State<PhnoicsCardsScreen> {
  final _repository = PhonicsCardsRepository();
  final _scrollController = ScrollController();
  final _cardsSectionKey = GlobalKey();

  List<PhonicsCard> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await _repository.fetchCards();
      if (!mounted) return;
      setState(() {
        _cards = payload.cards;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCards() {
    final target = _cardsSectionKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }
    _scrollController.animateTo(
      280,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  PhonicsCard? _firstPlayableCard(List<PhonicsCard> cards) {
    if (cards.isEmpty) return null;
    for (final card in cards) {
      if (card.status != 'locked') return card;
    }
    return cards.first;
  }

  void _openCardDeck(List<PhonicsCard> cards, PhonicsCard startCard) {
    final deckArgs = cards
        .map(
          (e) => PhonicsCardDetailArgs(
            image: e.displayDetailImageUrl,
            title: e.title,
            subtitle: e.displaySubtitle,
          ),
        )
        .toList(growable: false);
    final initialIndex = cards.indexWhere((e) => e.id == startCard.id);
    Navigator.pushNamed(
      context,
      AppRouter.phonicscardsdetail,
      arguments: PhonicsCardDeckArgs(
        cards: deckArgs,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
      ),
    );
  }

  void _startLearning() {
    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('No phonics cards are available right now.'))),
      );
      return;
    }
    final startCard = _firstPlayableCard(_cards);
    if (startCard == null) return;
    _openCardDeck(_cards, startCard);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                              Text(
                                context.tr('Phonics Cards'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromRGBO(21, 21, 21, 1),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                context.tr(
                                  'Master reading with ease. Focus, learn, and enjoy Flash Phonics Cards.',
                                ),
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
                            AppAssets.phonicsimage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _scrollToCards,
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 22,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        left: 0,
                                        child: _MiniAvatar(image: AppAssets.profileimage),
                                      ),
                                      Positioned(
                                        left: 14,
                                        child: _MiniAvatar(image: AppAssets.studentAvatar),
                                      ),
                                      Positioned(
                                        left: 28,
                                        child: _MiniAvatar(image: AppAssets.studentsimage),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  context.tr('Join 10,000+ Readers'),
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(21, 21, 21, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF43C2BD),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 64),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('Ready to play?'),
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: Colors.black.withOpacity(.90),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  context.tr(
                                    'Reading made simple. A quiet space for focus and Phonics mastery.',
                                  ),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.black.withOpacity(.70),
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 0,
                            child: Image.asset(
                              AppAssets.phonicsimage,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                        onTap: _startLearning,
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            ),
                            border: Border.all(
                              color: Colors.black.withOpacity(.06),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.playimage,
                                height: 24,
                                width: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                context.tr('Start Phonics Cards Learning'),
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
                    SizedBox(height: 18),
                    if (_loading)
                      SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Unable to load phonics cards. $_error',
                              style: textTheme.bodyMedium,
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: _loadCards,
                              child: Text(context.tr('Retry')),
                            ),
                          ],
                        ),
                      )
                    else if (_cards.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          context.tr('No phonics cards are available right now.'),
                          style: textTheme.bodyMedium,
                        ),
                      )
                    else
                      KeyedSubtree(
                        key: _cardsSectionKey,
                        child: _PhonicsCardsGrid(
                          textTheme: textTheme,
                          cards: _cards,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PhonicsCardsGrid extends StatelessWidget {
  const _PhonicsCardsGrid({
    required this.textTheme,
    required this.cards,
  });

  final TextTheme textTheme;
  final List<PhonicsCard> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _PhonicsCardTile(
        card: cards[index],
        deck: cards,
      ),
    );
  }
}

class _PhonicsCardTile extends StatelessWidget {
  const _PhonicsCardTile({
    required this.card,
    required this.deck,
  });

  final PhonicsCard card;
  final List<PhonicsCard> deck;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final cards = deck
              .map(
                (e) => PhonicsCardDetailArgs(
                  image: e.displayDetailImageUrl,
                  title: e.title,
                  subtitle: e.displaySubtitle,
                ),
              )
              .toList(growable: false);
          final initialIndex = deck.indexWhere((e) => e.id == card.id);
          Navigator.pushNamed(
            context,
            AppRouter.phonicscardsdetail,
            arguments: PhonicsCardDeckArgs(
              cards: cards,
              initialIndex: initialIndex < 0 ? 0 : initialIndex,
            ),
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card.title,
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0066CC),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  card.title,
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromRGBO(26, 28, 28, 1),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  card.displaySubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
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
