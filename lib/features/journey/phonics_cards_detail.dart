// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/media/network_media_image.dart';
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

class PhonicsCardsDetailScreen extends StatefulWidget {
  const PhonicsCardsDetailScreen({
    super.key,
    this.args,
  });

  final PhonicsCardDetailArgs? args;

  @override
  State<PhonicsCardsDetailScreen> createState() => _PhonicsCardsDetailScreenState();
}

class _PhonicsCardsDetailScreenState extends State<PhonicsCardsDetailScreen> with SingleTickerProviderStateMixin {
  int _index = 0;
  List<PhonicsCardDetailArgs> _cards = const [];
  late final AnimationController _flipController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Widget _buildFront(PhonicsCardDetailArgs? card) {
    if (card?.image.trim().isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    return NetworkMediaImage(
      url: card!.image.trim(),
      fit: BoxFit.contain,
    );
  }

  Widget _buildBack(PhonicsCardDetailArgs? card) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (card?.subtitle ?? '').toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(26, 28, 28, 1),
            ),
          ),
          SizedBox(height: 12),
          Icon(
            Icons.volume_up_rounded,
            size: 36,
            color: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

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
  }

  void _resetFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    }
    _isFlipped = false;
  }

  void _goPrev() {
    if (_cards.isEmpty) return;
    setState(() {
      _index = (_index - 1).clamp(0, _cards.length - 1);
      _resetFlip();
    });
  }

  void _goNext() {
    if (_cards.isEmpty) return;
    setState(() {
      _index = (_index + 1).clamp(0, _cards.length - 1);
      _resetFlip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards.isNotEmpty ? _cards[_index] : null;
    final total = _cards.isNotEmpty ? _cards.length : 1;
    final progress = total <= 0 ? 0.0 : (_index + 1) / total;

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

              SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: AnimatedBuilder(
                                  animation: _flipController,
                                  builder: (context, child) {
                                    final angle = _flipController.value * math.pi;
                                    final isFrontVisible = _flipController.value <= 0.5;
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle),
                                      child: isFrontVisible
                                          ? _buildFront(card)
                                          : Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()..rotateY(math.pi),
                                              child: _buildBack(card),
                                            ),
                                    );
                                  },
                                ),
                              ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          card?.title ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            color: const Color.fromRGBO(26, 28, 28, 1),
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          height: 40,
                          width: 160,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (card?.subtitle ?? '').toLowerCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.volume_up_rounded,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),
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
                              onTap: () {
                                if (_flipController.isAnimating) return;
                                if (_isFlipped) {
                                  _flipController.reverse();
                                } else {
                                  _flipController.forward();
                                }
                                setState(() {
                                  _isFlipped = !_isFlipped;
                                });
                              },
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


