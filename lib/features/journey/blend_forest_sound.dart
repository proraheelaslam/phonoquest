// ignore_for_file: unused_import, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/core/media/media_url.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_repository.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_forest_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_detail_screen_args.dart';
import 'package:phonoquest_signup_flow/features/journey/data/blend_sound_screen_args.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../core/l10n/app_language_controller.dart';

class blendForesrSoundScreen extends StatefulWidget {
  const blendForesrSoundScreen({super.key});

  @override
  State<blendForesrSoundScreen> createState() => _blendForesrSoundScreenState();
}

class _blendForesrSoundScreenState extends State<blendForesrSoundScreen> {
  final BlendForestRepository _repo = BlendForestRepository();
  String _digraph = 'SH';
  String? _lessonAudioUrl;
  List<BlendWordModel> _words = [];
  bool _loading = false;
  String? _error;
  final AudioPlayer _player = AudioPlayer();
  int? _lessonId;
  Object? _routeArg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    final Object? arg = ModalRoute.of(context)?.settings.arguments;
    _routeArg = arg;

    if (arg is BlendSoundScreenArgs) {
      _lessonId = arg.lessonId;
      setState(() {
        _digraph = arg.digraph;
        _lessonAudioUrl = arg.lessonAudioUrl;
        _words = arg.words;
      });
      if (arg.words.isEmpty && arg.lessonId > 0) {
        _fetchLesson(arg.lessonId);
      }
      return;
    }

    if (arg is int) {
      _lessonId = arg;
      _fetchLesson(arg);
    } else if (arg is String && arg.trim().isNotEmpty) {
      setState(() => _digraph = arg.trim().toUpperCase());
    }
  }

  Future<void> _fetchLesson(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await _repo.fetchLesson(id);
      if (!mounted) return;
      setState(() {
        _lessonId = payload.lesson.id;
        _digraph = payload.lesson.code.toUpperCase();
        _lessonAudioUrl = payload.lesson.audioUrl;
        _words = payload.words;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? '$e' : 'Could not load lesson';
        _loading = false;
      });
    }
  }

  Future<void> _playUrl(String? url) async {
    final candidates = playbackMediaCandidates(url);
    if (candidates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('No audio available.'))),
      );
      return;
    }

    Object? lastError;
    for (final source in candidates) {
      try {
        await _player.stop();
        await _player.setUrl(source);
        await _player.play();
        return;
      } catch (error) {
        lastError = error;
        debugPrint('Blend Forest audio try failed for url: $source error: $error');
      }
    }

    if (!mounted) return;
    debugPrint('Blend Forest audio failed for all sources: $candidates last: $lastError');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Could not play audio.'))),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayWords = _words.isNotEmpty
        ? _words
        : [
            BlendWordModel(id: 1, wordText: 'Ship', highlight: 'Sh'),
            BlendWordModel(id: 2, wordText: 'Fish', highlight: 'sh'),
            BlendWordModel(id: 3, wordText: 'Bush', highlight: 'sh'),
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
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
                    Text(
                      'DISCOVER \"$_digraph\"',
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
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.listenimage,
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8),
                    Text(context.tr('Tap to Listen'),
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
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
                            _DiscoverCard(
                              digraph: _digraph,
                              onPlay: () => _playUrl(_lessonAudioUrl),
                            ),
                            SizedBox(height: 18),
                            Text(
                              "Words with '$_digraph'",
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(26, 28, 28, 1),
                              ),
                            ),
                            SizedBox(height: 12),
                            for (int i = 0; i < displayWords.length; i++) ...[
                              _WordRow(
                                word: displayWords[i].wordText,
                                highlight: displayWords[i].highlightFor(_digraph),
                                onPlay: displayWords[i].audioUrl != null
                                    ? () => _playUrl(displayWords[i].audioUrl)
                                    : null,
                              ),
                              if (i != displayWords.length - 1) SizedBox(height: 12),
                            ],
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
              Center(
                child: SizedBox(
                  height: 56,
                  width: 300,
                  child: Material(
                    color: const Color(0xFF4ECBC1),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final Object? arg = _lessonId != null
                            ? BlendDetailScreenArgs(
                                lessonId: _lessonId!,
                                digraph: _digraph,
                              )
                            : _routeArg ?? _digraph;
                        Navigator.pushNamed(
                          context,
                          AppRouter.blendforestdetail,
                          arguments: arg,
                        );
                      },
                      child: Center(
                        child: Text(context.tr('NEXT'),
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color.fromRGBO(28, 28, 28, 1),
                          ),
                        ),
                      ),
                    ),
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

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.digraph,
    required this.onPlay,
  });

  final String digraph;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
              SizedBox(height: 8),
              Text(
                digraph,
                style: GoogleFonts.lexend(
                  fontSize: 80,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: const Color(0xFFF47495),
                ),
              ),
              SizedBox(height: 18),
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  color: Color(0xFF53C8C1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({
    required this.word,
    required this.highlight,
    this.onPlay,
  });

  final String word;
  final String highlight;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Text(
                word.isNotEmpty ? word[0].toUpperCase() : '?',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0066CC),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _HighlightedWord(
              word: word,
              highlight: highlight,
            ),
          ),
          SizedBox(
            width: 34,
            height: 34,
            child: InkWell(
              onTap: onPlay,
              child: Image.asset(
                AppAssets.redaudioimage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedWord extends StatelessWidget {
  const _HighlightedWord({required this.word, required this.highlight});

  final String word;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final String w = word;
    final String h = highlight;
    final int idx = w.toLowerCase().indexOf(h.toLowerCase());

    if (idx < 0) {
      return Text(
        word,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color.fromRGBO(26, 28, 28, 1),
        ),
      );
    }

    final String before = w.substring(0, idx);
    final String mid = w.substring(idx, idx + h.length);
    final String after = w.substring(idx + h.length);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color.fromRGBO(26, 28, 28, 1),
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: mid,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF47495),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
