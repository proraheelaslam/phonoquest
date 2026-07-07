// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/core/media/network_media_image.dart';
import 'package:phonoquest_signup_flow/core/media/media_url.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_detail_screen_args.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_repository.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_sound_screen_args.dart';
import 'package:phonoquest_signup_flow/features/journey/data/vowel_learning_models.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../core/l10n/app_language_controller.dart';

class blendForestDetailScreen extends StatefulWidget {
  const blendForestDetailScreen({super.key});

  @override
  State<blendForestDetailScreen> createState() => _blendForestDetailScreenState();
}

class _blendForestDetailScreenState extends State<blendForestDetailScreen> {
  final BlendForestRepository _repo = BlendForestRepository();
  final AudioPlayer _player = AudioPlayer();

  int? _lessonId;
  String _digraph = 'SH';
  bool _loading = false;
  bool _submitting = false;
  String? _error;
  WordBuilderRandomOut? _round;
  List<String> _ghostSlots = const [];
  List<String?> _placedSlots = const [];
  final Set<int> _usedTrayIndices = {};
  final Map<int, int> _slotToTrayIndex = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _bootstrap() {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    int? lessonId;

    if (args is BlendDetailScreenArgs) {
      lessonId = args.lessonId;
      if (args.digraph != null && args.digraph!.trim().isNotEmpty) {
        _digraph = args.digraph!.trim().toUpperCase();
      }
    } else if (args is BlendSoundScreenArgs) {
      lessonId = args.lessonId;
      _digraph = args.digraph;
    } else if (args is int) {
      lessonId = args;
    }

    if (lessonId != null && lessonId > 0) {
      _lessonId = lessonId;
      _loadWordBuilder();
      return;
    }

    setState(() {
      _error = 'Open a lesson from Blend Forest to use Word Builder.';
    });
  }

  Future<void> _loadWordBuilder() async {
    final id = _lessonId;
    if (id == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _usedTrayIndices.clear();
      _slotToTrayIndex.clear();
    });

    try {
      final lessonPayload = await _repo.fetchLesson(id);
      final round = await _repo.fetchWordBuilderRandom(id);

      BlendWordModel? targetWord;
      for (final w in lessonPayload.words) {
        if (w.id == round.wordId) {
          targetWord = w;
          break;
        }
      }
      targetWord ??= lessonPayload.words.isNotEmpty ? lessonPayload.words.first : null;

      final ghosts = targetWord != null && targetWord.tiles.isNotEmpty
          ? targetWord.tiles
          : round.tilePool.take(round.slotCount).toList();

      if (!mounted) return;
      setState(() {
        _round = round;
        _digraph = lessonPayload.lesson.code.toUpperCase();
        _ghostSlots = ghosts;
        _placedSlots = List<String?>.filled(round.slotCount, null);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? '$e' : 'Could not load word builder';
        _loading = false;
      });
    }
  }

  Future<void> _playWordAudio() async {
    final url = _round?.wordAudioUrl ?? _round?.lessonAudioUrl;
    final candidates = playbackMediaCandidates(url);
    if (candidates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('No audio available.'))),
      );
      return;
    }
    for (final source in candidates) {
      try {
        await _player.stop();
        await _player.setUrl(source);
        await _player.play();
        return;
      } catch (_) {}
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Could not play audio.'))),
    );
  }

  void _onTrayTileTap(int trayIndex) {
    if (_submitting || _round == null) return;
    if (_usedTrayIndices.contains(trayIndex)) return;

    final emptySlot = _placedSlots.indexWhere((slot) => slot == null);
    if (emptySlot < 0) return;

    final label = _round!.tilePool[trayIndex];
    setState(() {
      _placedSlots[emptySlot] = label;
      _usedTrayIndices.add(trayIndex);
      _slotToTrayIndex[emptySlot] = trayIndex;
    });

    if (!_placedSlots.contains(null)) {
      _submitWord();
    }
  }

  void _onDropSlotTap(int slotIndex) {
    if (_submitting) return;
    final trayIndex = _slotToTrayIndex.remove(slotIndex);
    if (trayIndex == null) return;
    setState(() {
      _placedSlots[slotIndex] = null;
      _usedTrayIndices.remove(trayIndex);
    });
  }

  Future<void> _submitWord() async {
    final id = _lessonId;
    final round = _round;
    if (id == null || round == null) return;

    final tiles = _placedSlots.whereType<String>().toList();
    if (tiles.length != round.slotCount) return;

    setState(() => _submitting = true);

    try {
      final result = await _repo.submitWordBuilder(
        lessonId: id,
        wordId: round.wordId,
        tiles: tiles,
      );
      if (!mounted) return;

      setState(() => _submitting = false);

      if (result.correct) {
        Navigator.pushNamed(context, AppRouter.blendforestdcomplete);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Not quite — try again.')),
          backgroundColor: const Color(0xFFF87171),
        ),
      );
      setState(() {
        _placedSlots = List<String?>.filled(round.slotCount, null);
        _usedTrayIndices.clear();
        _slotToTrayIndex.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;

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
                        child: SizedBox(
                          width: 36,
                          height: 36,
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
                    Text(context.tr('Blend Forest'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(26, 28, 28, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                            _WordBuilderCard(
                              digraph: _digraph,
                              instruction: round?.instruction ??
                                  "Let's build a word with the '$_digraph' blend!",
                              imageUrl: round?.imageUrl,
                              targetWord: round?.targetWordDisplay ?? '',
                            ),
                            SizedBox(height: 16),
                            _DropTilesArea(
                              ghostSlots: _ghostSlots,
                              placedSlots: _placedSlots,
                              onSlotTap: _onDropSlotTap,
                              onHearWord: _playWordAudio,
                            ),
                            SizedBox(height: 16),
                            if (round != null)
                              _LetterTray(
                                tilePool: round.tilePool,
                                usedIndices: _usedTrayIndices,
                                onTileTap: _onTrayTileTap,
                              ),
                            if (_submitting)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Center(child: CircularProgressIndicator()),
                              ),
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

class _WordBuilderCard extends StatelessWidget {
  const _WordBuilderCard({
    required this.digraph,
    required this.instruction,
    required this.imageUrl,
    required this.targetWord,
  });

  final String digraph;
  final String instruction;
  final String? imageUrl;
  final String targetWord;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.tr('Word Builder Lab'),
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color.fromRGBO(0, 102, 204, 1),
          ),
        ),
        SizedBox(height: 6),
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: const Color(0xFF667085),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 230,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 240,
                        height: 200,
                        child: NetworkMediaImage(
                          url: imageUrl,
                          width: 240,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAC515),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          targetWord.isNotEmpty ? targetWord.toUpperCase() : 'Target',
                          style: GoogleFonts.lexend(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(28, 28, 28, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropTilesArea extends StatelessWidget {
  const _DropTilesArea({
    required this.ghostSlots,
    required this.placedSlots,
    required this.onSlotTap,
    required this.onHearWord,
  });

  final List<String> ghostSlots;
  final List<String?> placedSlots;
  final void Function(int index) onSlotTap;
  final VoidCallback onHearWord;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.tr('DROP TILES HERE'),
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF98A2B3),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < placedSlots.length; i++) ...[
                if (i > 0) SizedBox(width: 16),
                _DropCircle(
                  ghostLabel: i < ghostSlots.length ? ghostSlots[i] : '',
                  placedLabel: placedSlots[i],
                  onTap: () => onSlotTap(i),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 56,
              width: 170,
              child: Material(
                color: const Color(0xFFF47495),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onHearWord,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          size: 20,
                          color: Color.fromRGBO(28, 28, 28, 1),
                        ),
                        SizedBox(width: 8),
                        Text(context.tr('Hear Word'),
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}

class _DropCircle extends StatelessWidget {
  const _DropCircle({
    required this.ghostLabel,
    required this.placedLabel,
    required this.onTap,
  });

  final String ghostLabel;
  final String? placedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool filled = placedLabel != null && placedLabel!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _DashedCirclePainter(
              color: filled ? const Color(0xFFF47495) : const Color(0xFFD8DDE6),
              strokeWidth: 2,
              dashLength: 7,
              gapLength: 6,
            ),
            child: Center(
              child: Text(
                filled ? placedLabel! : ghostLabel,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: filled
                      ? const Color.fromRGBO(28, 28, 28, 1)
                      : const Color(0xFFD0D5DD),
                ),
              ),
            ),
          ),
        ),
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

class _LetterTray extends StatelessWidget {
  const _LetterTray({
    required this.tilePool,
    required this.usedIndices,
    required this.onTileTap,
  });

  final List<String> tilePool;
  final Set<int> usedIndices;
  final void Function(int index) onTileTap;

  static const _tileColors = [
    Color(0xFFF47495),
    Color(0xFF1E8E3E),
    Colors.white,
    Color(0xFFFAC515),
  ];

  @override
  Widget build(BuildContext context) {
    final rows = <List<int>>[];
    if (tilePool.length <= 3) {
      rows.add(List.generate(tilePool.length, (i) => i));
    } else {
      rows.add(List.generate(3, (i) => i));
      rows.add(List.generate(tilePool.length - 3, (i) => i + 3));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E6EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.tr('Letter Tray'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(26, 28, 28, 1),
            ),
          ),
          SizedBox(height: 16),
          for (int r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) SizedBox(width: 14),
                  _LetterTile(
                    label: tilePool[rows[r][c]],
                    color: _tileColors[rows[r][c] % _tileColors.length],
                    used: usedIndices.contains(rows[r][c]),
                    onTap: () => onTileTap(rows[r][c]),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.label,
    required this.color,
    required this.used,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const textColor = Color.fromRGBO(28, 28, 28, 1);

    return Opacity(
      opacity: used ? 0.35 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: used ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: color == Colors.white
                  ? Border.all(color: const Color(0xFFE4E7EC))
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
