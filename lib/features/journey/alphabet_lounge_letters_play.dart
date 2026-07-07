// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_repository.dart';
import 'package:phonoquest_signup_flow/core/media/media_url.dart';
import 'package:phonoquest_signup_flow/features/journey/widgets/alphabet_word_thumbnail.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

class lettersPlayScreen extends StatefulWidget {
  const lettersPlayScreen({super.key});

  @override
  State<lettersPlayScreen> createState() => _lettersPlayScreenState();
}

class _lettersPlayScreenState extends State<lettersPlayScreen> {
  final AudioPlayer _player = AudioPlayer();
  final AlphabetLoungeRepository _repo = AlphabetLoungeRepository();

  int? _letterId;
  String _pair = 'Ss';
  LetterDetailPayload? _detail;
  bool _loading = false;
  String? _error;

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
      final d = await _repo.fetchLetterDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _pair = d.pairLabel;
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

  Future<void> _playUrl(String url) async {
    final candidates = playbackMediaCandidates(url);
    for (final source in candidates) {
      try {
        await _player.setUrl(source);
        await _player.play();
        return;
      } catch (_) {
        continue;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Could not play audio.'))),
    );
  }

  String _letterFromPair(String pair) {
    final cleaned = pair.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return 'S';
    return cleaned.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final pair = _detail?.pairLabel ?? _pair;
    final letter = _letterFromPair(pair);

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
                                AppRouter.alphabet,
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
                  InkWell(
                    onTap: () {
                      final u = _detail?.phonicsAudioUrl;
                      if (u != null && u.isNotEmpty) {
                        _playUrl(u);
                      }
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Center(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black.withOpacity(.06)),
                        ),
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
                    ),
                  ),
                  SizedBox(height: 14),
                  Expanded(
                    child: _loading && _letterId != null
                        ? Center(child: CircularProgressIndicator())
                        : _error != null && _detail == null && _letterId != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xFF475467)),
                                    ),
                                    SizedBox(height: 12),
                                    TextButton(onPressed: _load, child: Text(context.tr('Retry'))),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            pair,
                                            style: GoogleFonts.lexend(
                                              fontSize: 80,
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                              color: const Color.fromRGBO(0, 102, 204, 1),
                                            ),
                                          ),
                                          SizedBox(height: 18),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              customBorder: const CircleBorder(),
                                              onTap: () {
                                                final u = _detail?.phonicsAudioUrl;
                                                if (u != null && u.isNotEmpty) {
                                                  _playUrl(u);
                                                }
                                              },
                                              child: SizedBox(
                                                width: 68,
                                                height: 68,
                                                child: Image.asset(
                                                  AppAssets.tractileimage,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 18),
                                    Text(
                                      "Words with '$letter'",
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color.fromRGBO(26, 28, 28, 1),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    if (_detail != null && _detail!.words.isNotEmpty)
                                      ..._detail!.words.map(
                                        (w) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _WordRow(
                                            word: w.wordText,
                                            imageUrl: w.imageUrl,
                                            onPlayTap: (w.audioUrl != null && w.audioUrl!.isNotEmpty)
                                                ? () => _playUrl(w.audioUrl!)
                                                : null,
                                          ),
                                        ),
                                      )
                                    else ...[
                                      const _WordRow(
                                        assetImage: AppAssets.sunimage,
                                        word: 'Sun',
                                      ),
                                      SizedBox(height: 12),
                                      const _WordRow(
                                        assetImage: AppAssets.starsimage,
                                        word: 'Star',
                                      ),
                                      SizedBox(height: 12),
                                      const _WordRow(
                                        assetImage: AppAssets.sockimage,
                                        word: 'Sock',
                                      ),
                                    ],
                                    SizedBox(height: 24),
                                  ],
                                ),
                              ),
                  ),
                  SizedBox(
                    height: 52,
                    child: Material(
                      color: const Color(0xFF4ECBC1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.lettersplaysound,
                            arguments: _letterId,
                          );
                        },
                        child: Center(
                          child: Text(context.tr('NEXT ALPHABET'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({
    required this.word,
    this.assetImage,
    this.imageUrl,
    this.onPlayTap,
  });

  final String word;
  final String? assetImage;
  final String? imageUrl;
  final VoidCallback? onPlayTap;

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
            child: Center(
              child: assetImage != null
                  ? Image.asset(
                      assetImage!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    )
                  : AlphabetWordThumbnail(
                      word: word,
                      networkUrl: imageUrl,
                      size: 36,
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              word,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(26, 28, 28, 1),
              ),
            ),
          ),
          InkWell(
            onTap: onPlayTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                AppAssets.redaudioimage,
                width: 34,
                height: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
