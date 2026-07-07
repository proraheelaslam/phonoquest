// ignore_for_file: unused_import, prefer_const_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_repository.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

class lettersPlaySoundScreen extends StatefulWidget {
  const lettersPlaySoundScreen({super.key});

  @override
  State<lettersPlaySoundScreen> createState() => _lettersPlaySoundScreenState();
}

class _lettersPlaySoundScreenState extends State<lettersPlaySoundScreen>
    with TickerProviderStateMixin {
  final AlphabetLoungeRepository _repo = AlphabetLoungeRepository();
  late final AnimationController _floatController;

  int? _letterId;
  String _pair = 'Ss';
  FindSoundActivityPayload? _activity;
  bool _loading = false;
  String? _error;
  bool _submitting = false;
  final Map<int, LetterDetailPayload> _detailCache = {};

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _bootstrap() {
    if (!mounted) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      setState(() {
        _letterId = arg;
        _loading = true;
      });
      _load();
    } else if (arg is String && arg.trim().isNotEmpty) {
      setState(() {
        _pair = arg.trim();
        _letterId = null;
        _loading = false;
      });
    } else {
      setState(() {
        _pair = 'Ss';
        _letterId = null;
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    final id = _letterId;
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final a = await _repo.fetchFindSoundActivity(id);
      if (!mounted) return;
      setState(() {
        _activity = a;
        if (a.targetUppercase.isNotEmpty) {
          _pair = '${a.targetUppercase}${a.targetUppercase.toLowerCase()}';
        }
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _letterFromPair(String pair) {
    final cleaned = pair.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return 'S';
    return cleaned.substring(0, 1).toUpperCase();
  }

  String _pairFromRouteFallback() {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.trim().isNotEmpty) return arg.trim();
    return 'Ss';
  }

  Future<void> _onBubbleTap(FindSoundBubbleModel bubble) async {
    final letterId = _letterId;
    if (letterId == null || _submitting) return;
    setState(() => _submitting = true);

    int? selectedWordId = bubble.preferredSelectedWordId;

    // If activity didn't provide a word id for this bubble, fetch the letter detail
    // for that bubble's letter and use the first available word id as the submission id.
    if (selectedWordId == null) {
      try {
        final bid = bubble.letterId;
        LetterDetailPayload? detail = _detailCache[bid];
        if (detail == null) {
          detail = await _repo.fetchLetterDetail(bid);
          _detailCache[bid] = detail;
        }
        if (detail.words.isNotEmpty) {
          selectedWordId = detail.words.first.id;
        }
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('Could not load word for selected bubble: ')}${e.message}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF991B1B),
          ),
        );
        if (mounted) setState(() => _submitting = false);
        return;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not determine the word for this bubble.')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF991B1B),
          ),
        );
        if (mounted) setState(() => _submitting = false);
        return;
      }
    }

    if (selectedWordId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('No word available to submit for this bubble.')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF991B1B),
          ),
        );
        setState(() => _submitting = false);
      }
      return;
    }

    try {
      final result = await _repo.submitFindSoundSelection(letterId, selectedWordId);
      if (!mounted) return;

      if (result.correct) {
        final coins = result.rewardAppliedCoins;
        final successText = coins > 0 ? 'Correct! +$coins coins' : 'Correct! Great match.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successText),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F766E),
            duration: const Duration(seconds: 2),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        Navigator.pushNamed(context, AppRouter.alphabetloungehero);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Not quite — tap the letter that matches this sound.')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF991B1B),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Something went wrong. Please try again.')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildPromptRich(String letter) {
    final activity = _activity;
    if (activity != null && activity.prompt.trim().isNotEmpty) {
      final highlight = activity.targetUppercase.isNotEmpty ? activity.targetUppercase : letter;
      final p = activity.prompt;
      final idx = p.indexOf(highlight);
      if (idx >= 0 && highlight.isNotEmpty) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(26, 28, 28, 1),
            ),
            children: [
              TextSpan(text: p.substring(0, idx)),
              TextSpan(
                text: p.substring(idx, idx + highlight.length),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF47495),
                ),
              ),
              TextSpan(text: p.substring(idx + highlight.length)),
            ],
          ),
        );
      }
      return Text(
        p,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color.fromRGBO(26, 28, 28, 1),
        ),
      );
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color.fromRGBO(26, 28, 28, 1),
        ),
        children: [
          TextSpan(text: context.tr('Find the ')),
          TextSpan(
            text: '"$letter"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF47495),
            ),
          ),
          TextSpan(text: context.tr(' sound!')),
        ],
      ),
    );
  }

  List<Widget> _buildBubbleStackChildren(String letter) {
    final id = _letterId;
    final activity = _activity;

    if (id != null && activity != null && activity.bubbles.isNotEmpty) {
      final targetId = activity.targetLetterId;
      late final FindSoundBubbleModel targetBubble;
      final byId = activity.bubbles.where((b) => b.letterId == targetId).toList();
      if (byId.isNotEmpty) {
        targetBubble = byId.first;
      } else {
        final bySym =
            activity.bubbles.where((b) => b.symbol.toUpperCase() == activity.targetUppercase.toUpperCase()).toList();
        targetBubble = bySym.isNotEmpty ? bySym.first : activity.bubbles.first;
      }
      final others = activity.bubbles.where((b) => b.letterId != targetBubble.letterId).toList();

      const otherLayouts = <_BubbleLayout>[
        _BubbleLayout(left: 26, top: 150, size: 92, color: Color(0xFF2FB344), labelColor: Colors.white),
        _BubbleLayout(left: 105, top: 175, size: 62, color: Color(0xFFDDE2EA), labelColor: Color(0xFF667085)),
        _BubbleLayout(left: 102, top: 305, size: 72, color: Color(0xFFFAC515), labelColor: Color.fromRGBO(26, 28, 28, 1)),
      ];

      final out = <Widget>[];
      for (var i = 0; i < others.length && i < otherLayouts.length; i++) {
        final b = others[i];
        final layout = otherLayouts[i];
        out.add(
          Positioned(
            left: layout.left,
            top: layout.top,
            child: _FloatingBubbleWrap(
              controller: _floatController,
              phase: layout.left * 0.01 + layout.top * 0.002,
              child: _TappableLetterBubble(
                label: b.symbol,
                color: layout.color,
                size: layout.size,
                labelColor: layout.labelColor,
                enabled: !_submitting,
                onTap: () => _onBubbleTap(b),
              ),
            ),
          ),
        );
      }

      out.add(
        Positioned(
          right: 46,
          top: 235,
          child: _FloatingBubbleWrap(
            controller: _floatController,
            phase: 2.1,
            child: _TappableLetterBubble(
              label: targetBubble.symbol,
              color: const Color(0xFFF47495),
              size: 108,
              enabled: !_submitting,
              onTap: () => _onBubbleTap(targetBubble),
            ),
          ),
        ),
      );
      out.add(
        const Positioned(
          right: 30,
          top: 265,
          child: Icon(
            Icons.music_note_rounded,
            size: 22,
            color: Color(0xFFF47495),
          ),
        ),
      );
      return out;
    }

    return [
      Positioned(
        left: 26,
        top: 150,
        child: _FloatingBubbleWrap(
          controller: _floatController,
          phase: 0,
          child: const _LetterBubble(
            label: 'A',
            color: Color(0xFF2FB344),
            size: 92,
          ),
        ),
      ),
      Positioned(
        left: 105,
        top: 175,
        child: _FloatingBubbleWrap(
          controller: _floatController,
          phase: 0.7,
          child: const _LetterBubble(
            label: 'B',
            color: Color(0xFFDDE2EA),
            labelColor: Color(0xFF667085),
            size: 62,
          ),
        ),
      ),
      Positioned(
        left: 102,
        top: 305,
        child: _FloatingBubbleWrap(
          controller: _floatController,
          phase: 1.4,
          child: const _LetterBubble(
            label: 'C',
            color: Color(0xFFFAC515),
            labelColor: Color.fromRGBO(26, 28, 28, 1),
            size: 72,
          ),
        ),
      ),
      Positioned(
        right: 46,
        top: 235,
        child: _FloatingBubbleWrap(
          controller: _floatController,
          phase: 2.1,
          child: _LetterBubble(
            label: letter,
            color: const Color(0xFFF47495),
            size: 108,
          ),
        ),
      ),
      const Positioned(
        right: 30,
        top: 265,
        child: Icon(
          Icons.music_note_rounded,
          size: 22,
          color: Color(0xFFF47495),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pair = _activity != null ? _pair : _pairFromRouteFallback();
    final letter = _letterFromPair(pair);
    final showLoading = _loading && _letterId != null;
    final showError = _error != null && _activity == null && _letterId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                                return;
                              }
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.lettersplay,
                              );
                            },
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
                        Text(
                          'Letter $letter Play',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromRGBO(26, 28, 28, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Expanded(
                    child: showLoading
                        ? Center(child: CircularProgressIndicator())
                        : showError
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        color: const Color(0xFF475467),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    TextButton(onPressed: _load, child: Text(context.tr('Retry'))),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 14,
                                        right: 14,
                                        top: 14,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.72),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: _buildPromptRich(letter),
                                        ),
                                      ),
                                      ..._buildBubbleStackChildren(letter),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleLayout {
  const _BubbleLayout({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.labelColor,
  });

  final double left;
  final double top;
  final double size;
  final Color color;
  final Color labelColor;
}

class _FloatingBubbleWrap extends StatelessWidget {
  const _FloatingBubbleWrap({
    required this.controller,
    required this.phase,
    required this.child,
  });

  final AnimationController controller;
  final double phase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        final dy = 5 * math.sin(2 * math.pi * v + phase);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }
}

class _TappableLetterBubble extends StatelessWidget {
  const _TappableLetterBubble({
    required this.label,
    required this.color,
    required this.size,
    this.labelColor = Colors.white,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final double size;
  final Color labelColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: _LetterBubble(
          label: label,
          color: color,
          size: size,
          labelColor: labelColor,
        ),
      ),
    );
  }
}

class _LetterBubble extends StatelessWidget {
  const _LetterBubble({
    required this.label,
    required this.color,
    required this.size,
    this.labelColor = Colors.white,
  });

  final String label;
  final Color color;
  final double size;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: size * 0.48,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
      ),
    );
  }
}
