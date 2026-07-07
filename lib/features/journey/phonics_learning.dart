// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../core/l10n/app_language_controller.dart';

class PhonicsCardDetailArgs {
  const PhonicsCardDetailArgs({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

String _formatTitle(String raw) {
  if (raw.isEmpty) return raw;

  final cleaned = raw.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.isEmpty) return raw;

  final upper = cleaned.substring(0, 1).toUpperCase();
  final lower = cleaned.length > 1
      ? cleaned.substring(1, 2).toLowerCase()
      : upper.toLowerCase();

  return '$upper $lower';
}

class _LearningSoundRow extends StatelessWidget {
  const _LearningSoundRow({
    required this.image,
    required this.phoneme,
    required this.word,
    required this.isActive,
  });

  final String image;
  final String phoneme;
  final String word;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: image.isNotEmpty
                    ? Image.asset(image, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phoneme,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromRGBO(26, 28, 28, 1),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  word,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromRGBO(0, 102, 204, 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF47495) : const Color(0xFFEDEFF2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volume_up_rounded,
              size: 20,
              color: isActive
                  ? const Color.fromRGBO(28, 28, 28, 1)
                  : const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withOpacity(.06), width: 1),
          ),
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? const Color.fromRGBO(28, 28, 28, 1)
                : const Color.fromRGBO(28, 28, 28, .25),
          ),
        ),
      ),
    );
  }
}

class PhonicsCardDeckArgs {
  const PhonicsCardDeckArgs({
    required this.cards,
    required this.initialIndex,
  });

  final List<PhonicsCardDetailArgs> cards;
  final int initialIndex;
}

class PhonicsLearningScreen extends StatefulWidget {
  const PhonicsLearningScreen({
    super.key,
    this.args,
  });

  final PhonicsCardDetailArgs? args;

  @override
  State<PhonicsLearningScreen> createState() => _PhonicsLearningScreenState();
}

class _PhonicsLearningScreenState extends State<PhonicsLearningScreen> {
  int _index = 0;
  List<PhonicsCardDetailArgs> _cards = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeArgs = ModalRoute.of(context)?.settings.arguments;

    if (_cards.isNotEmpty) return;

    if (widget.args != null) {
      _cards = [widget.args!];
      _index = 0;
      return;
    }

    if (routeArgs is PhonicsCardDeckArgs) {
      _cards = routeArgs.cards;
      _index = routeArgs.initialIndex.clamp(0, (_cards.isEmpty ? 0 : _cards.length - 1));
      return;
    }

    if (routeArgs is PhonicsCardDetailArgs) {
      _cards = [routeArgs];
      _index = 0;
      return;
    }

    _cards = const [
      PhonicsCardDetailArgs(
        image: AppAssets.appleimage,
        title: 'A',
        subtitle: 'apple',
      ),
    ];
    _index = 0;
  }

  void _goPrev() {
    if (_cards.isEmpty) return;
    setState(() {
      _index = (_index - 1).clamp(0, _cards.length - 1);
    });
  }

  void _goNext() {
    if (_cards.isEmpty) return;
    setState(() {
      _index = (_index + 1).clamp(0, _cards.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards.isNotEmpty ? _cards[_index] : null;
    final total = _cards.isNotEmpty ? _cards.length : 1;
    final progress = total <= 0 ? 0.0 : (_index + 1) / total;

    final displayTitle = _formatTitle(card?.title ?? '').isNotEmpty
        ? _formatTitle(card?.title ?? '')
        : 'A a';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
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
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(context.tr('Phonics Cards'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(26, 28, 28, 1),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 14,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_border_rounded,
                              size: 16,
                              color: Color.fromRGBO(28, 28, 28, 1),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${_index + 1} / $total',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(28, 28, 28, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),

              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 6,
                  color: const Color(0xFFEDEFF2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        color: const Color(0xFF1F8A70),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 290),
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 3,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(247, 205, 135, 1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          displayTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            color: const Color.fromRGBO(26, 28, 28, 1),
                          ),
                        ),
                        SizedBox(height: 18),
                        _LearningSoundRow(
                          image: AppAssets.redappleimage,
                          phoneme: '/æ/ as in',
                          word: (card?.subtitle ?? 'apple').toLowerCase(),
                          isActive: true,
                        ),
                        SizedBox(height: 12),
                        _LearningSoundRow(
                          image: AppAssets.monkeyfaceimage,
                          phoneme: '/eɪ/ as in',
                          word: 'ape',
                          isActive: false,
                        ),
                        SizedBox(height: 12),
                        _LearningSoundRow(
                          image: AppAssets.sleepingimage,
                          phoneme: '/ə/ as in',
                          word: 'asleep',
                          isActive: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 22),
              Row(
                children: [
                  _NavCircleButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _goPrev,
                    enabled: _index > 0,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 190,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF47495),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {Navigator.pushNamed(context, AppRouter.greatjob);},
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sync_alt_rounded,
                                      size: 18,
                                      color: Color.fromRGBO(28, 28, 28, 1),
                                    ),
                                    SizedBox(width: 10),
                                    Text(context.tr('Flip Card'),
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color.fromRGBO(28, 28, 28, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  _NavCircleButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _goNext,
                    enabled: _cards.isNotEmpty && _index < _cards.length - 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



}


