// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/features/journey/data/vowel_learning_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/vowel_learning_repository.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../core/l10n/app_language_controller.dart';


class VowelLearningDetailScreen extends StatefulWidget {
  const VowelLearningDetailScreen({super.key});

  @override
  State<VowelLearningDetailScreen> createState() => _VowelLearningDetailScreenState();
}

class _VowelLearningDetailScreenState extends State<VowelLearningDetailScreen> {
  final VowelLearningRepository _repo = VowelLearningRepository();
  final AudioPlayer _player = AudioPlayer();
  VowelLessonModel? _lessonModel;
  WordBuilderRandomOut? _round;
  bool _loadingRound = true;
  bool _submitting = false;
  String? _placedLetter;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final Object? args = ModalRoute.of(context)?.settings.arguments;
      if (args is VowelLessonModel) {
        _lessonModel = args;
      } else if (args is String && args.trim().isNotEmpty) {
        _lessonModel = _lessonModelFromKey(args.trim());
      }
      _loadRound();
    }
  }

  Future<void> _loadRound() async {
    final lesson = _lessonModel;
    if (lesson == null || lesson.id <= 0) {
      setState(() {
        _loadingRound = false;
        _errorMessage = 'Unable to load lesson data.';
      });
      return;
    }

    setState(() {
      _loadingRound = true;
      _errorMessage = null;
      _placedLetter = null;
    });

    try {
      final round = await _repo.fetchWordBuilderRandom(lesson.id);
      if (!mounted) return;
      setState(() {
        _round = round;
        _loadingRound = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRound = false;
        _errorMessage = e is Exception ? '$e' : 'Could not load the word round.';
      });
    }
  }

  String? get _effectiveAudioUrl {
    final candidate = _lessonModel?.audioUrl ?? _round?.lessonAudioUrl ?? _round?.wordAudioUrl;
    if (candidate == null) return null;
    final trimmed = candidate.trim();
    return trimmed.isNotEmpty ? trimmed : null;
  }

  Future<void> _playAudio() async {
    final url = _effectiveAudioUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('No audio available for this lesson.'))),
      );
      return;
    }

    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (error) {
      if (!mounted) return;
      debugPrint('Vowel audio playback failed for url: $url error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Could not play audio.'))),
      );
    }
  }

  Future<void> _submitTile(String letter) async {
    final lesson = _lessonModel;
    final round = _round;
    if (lesson == null || round == null) {
      return;
    }

    setState(() {
      _placedLetter = letter;
      _submitting = true;
    });

    try {
      final result = await _repo.submitWordBuilder(
        lessonId: lesson.id,
        wordId: round.wordId,
        vowelLetter: letter,
      );
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      if (result.correct) {
        Navigator.pushNamed(context, AppRouter.vowellearningcomplete);
        return;
      }

      final snack = SnackBar(
        content: Text(context.tr('Not quite — try again.')),
        backgroundColor: const Color(0xFFF87171),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
      });
      final snack = SnackBar(
        content: Text('${context.tr('Error: ')}${e.toString()}'),
        backgroundColor: const Color(0xFFF87171),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  VowelLessonModel _lessonModelFromKey(String key) {
    final String k = key.trim().toLowerCase();
    if (k == 'apple') {
      return const VowelLessonModel(
        id: 102,
        code: 'magic_e',
        title: 'Apple',
        soundLabel: 'Magic E Rule',
        iconUrl: null,
        audioUrl: null,
        exampleWordsPill: 'cake',
        masteryPercent: 0,
        status: 'unlocked',
      );
    }
    return VowelLessonModel(
      id: 102,
      code: 'magic_e',
      title: key,
      soundLabel: 'Magic E Rule',
      iconUrl: null,
      audioUrl: null,
      exampleWordsPill: key,
      masteryPercent: 0,
      status: 'unlocked',
    );
  }

  String _targetWordDisplay() {
    final title = _lessonModel?.title.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    if ((_round?.targetWordDisplay ?? '').isNotEmpty == true) {
      return _round!.targetWordDisplay;
    }
    return 'Word';
  }

  String _currentVowel() {
    if (_round != null && _round!.targetWordDisplay.length > _round!.vowelSlotIndex) {
      return _round!.targetWordDisplay[_round!.vowelSlotIndex].toUpperCase();
    }
    final title = _lessonModel?.title ?? '';
    final found = title.toLowerCase().split('').firstWhere(
          (ch) => 'aeiou'.contains(ch),
          orElse: () => 'a',
        );
    return found.toUpperCase();
  }

  List<String> _availableTiles() {
    if (_round != null && _round!.tilePool.isNotEmpty) {
      return _round!.tilePool.map((tile) => tile.toUpperCase()).toList();
    }
    final fallback = _lessonModel?.exampleWordsPill ?? '';
    if (fallback.isNotEmpty) {
      return fallback.split('').map((ch) => ch.toUpperCase()).toList();
    }
    return const ['A', 'E', 'I'];
  }

  @override
  Widget build(BuildContext context) {
    final targetWord = _targetWordDisplay();
    final vowel = _currentVowel();
    final tiles = _availableTiles();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
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
                            color: Color(0xFFF47495),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.backIcon,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(context.tr('Vowel Learning'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(26, 28, 28, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LessonCard(
                        targetWord: targetWord,
                        onListen: _effectiveAudioUrl != null ? _playAudio : null,
                      ),
                      if (_loadingRound)
                        Center(child: CircularProgressIndicator())
                      else if (_errorMessage != null)
                        Center(
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        )
                      else ...[
                        _LetterTrayCard(tilePool: tiles, onTileTap: _submitting ? null : _submitTile),
                        SizedBox(height: 16),
                        _DropTilesCard(vowel: vowel, placedLetter: _placedLetter),
                      ],
                      SizedBox(height: 18),
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

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.targetWord, this.onListen});

  final String targetWord;
  final VoidCallback? onListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  elevation: onListen != null ? 6 : 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: onListen,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: onListen != null ? const Color(0xFFFCE8EF) : const Color(0xFFF2F4F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up,
                        size: 34,
                        color: onListen != null ? const Color(0xFFF26B84) : const Color(0xFF98A2B3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  onListen != null ? 'Tap to play audio' : 'Audio unavailable',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color.fromRGBO(26, 28, 28, 1),
              ),
              children: [

                TextSpan(
                  text: '"$targetWord"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF47495),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Text(context.tr('Listen and match the correct vowel'),
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropTilesCard extends StatelessWidget {
  const _DropTilesCard({required this.vowel, this.placedLetter});

  final String vowel;
  final String? placedLetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(context.tr('Drop the Correct Vowel Word'),
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF98A2B3),
            ),
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedLetterDrop(
                vowel: vowel,
                placedLetter: placedLetter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _DropSpotKind { vowel }

class _DropSpot extends StatelessWidget {
  const _DropSpot({super.key, required this.kind, this.label});

  final _DropSpotKind kind;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bool isVowel = kind == _DropSpotKind.vowel;
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: isVowel ? const Color(0xFFB6D3FF) : const Color(0xFFD8DDE6),
          strokeWidth: 2,
          dashLength: 7,
          gapLength: 6,
        ),
        child: Center(
          child: isVowel
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VOWEL',
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                    SizedBox(height: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF98A2B3),
                    ),
                  ],
                )
              : const Icon(
                  Icons.add,
                  size: 20,
                  color: Color(0xFFD0D5DD),
                ),
        ),
      ),
    );
  }
}

class _DropCircle extends StatelessWidget {
  const _DropCircle({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: const Color(0xFFD8DDE6),
          strokeWidth: 2,
          dashLength: 7,
          gapLength: 6,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(28, 28, 28, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLetterDrop extends StatelessWidget {
  const _AnimatedLetterDrop({required this.vowel, this.placedLetter});

  final String vowel;
  final String? placedLetter;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.6),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: placedLetter == null
          ? _DropSpot(
              key: const ValueKey('placeholder'),
              kind: _DropSpotKind.vowel,
              label: vowel,
            )
          : _DropCircle(
              key: ValueKey('placed_${placedLetter!}'),
              label: placedLetter!,
            ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double circumference = 2 * 3.1415926535897932 * radius;

    final double dashPlusGap = dashLength + gapLength;
    final int dashCount = (circumference / dashPlusGap).floor().clamp(6, 200);
    final double sweep = (2 * 3.1415926535897932) / dashCount;
    final double dashSweep = sweep * (dashLength / dashPlusGap);

    for (int i = 0; i < dashCount; i++) {
      final double start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

class _LetterTrayCard extends StatelessWidget {
  const _LetterTrayCard({required this.tilePool, this.onTileTap});

  final List<String> tilePool;
  final void Function(String)? onTileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Text(context.tr('Letter Tray'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: tilePool
                .map((tile) => _TrayTile(label: tile, onTap: onTileTap))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TrayTile extends StatelessWidget {
  const _TrayTile({
    required this.label,
    this.onTap,
  });

  final String label;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap == null ? null : () => onTap!(label),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC), width: 1.4),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromRGBO(28, 28, 28, 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


