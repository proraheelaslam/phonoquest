// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/alphabet_lounge_repository.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

class AlphabetLoungeScreen extends StatefulWidget {
  const AlphabetLoungeScreen({super.key});

  @override
  State<AlphabetLoungeScreen> createState() => _AlphabetLoungeScreenState();
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF43C2BD),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: Color.fromRGBO(28, 28, 28, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterTileData {
  const _LetterTileData({
    required this.letterId,
    required this.pair,
    required this.color,
    required this.enabled,
    required this.underlineColor,
    required this.selected,
    required this.locked,
    this.phonicsAudioUrl,
  });

  final int letterId;
  final String pair;
  final Color color;
  final bool enabled;
  final Color underlineColor;
  final bool selected;
  final bool locked;
  final String? phonicsAudioUrl;

  static _LetterTileData fromApiLetter(LoungeLetterModel l) {
    switch (l.status) {
      case 'completed':
        return _LetterTileData(
          letterId: l.letterId,
          pair: l.pairLabel,
          color: const Color(0xFF2E6BE6),
          underlineColor: const Color(0xFFF47495),
          enabled: true,
          selected: true,
          locked: false,
          phonicsAudioUrl: l.phonicsAudioUrl,
        );
      case 'in_progress':
        return _LetterTileData(
          letterId: l.letterId,
          pair: l.pairLabel,
          color: const Color(0xFFF59E0B),
          underlineColor: const Color(0xFF0B63CE),
          enabled: true,
          selected: false,
          locked: false,
          phonicsAudioUrl: l.phonicsAudioUrl,
        );
      default:
        return _LetterTileData(
          letterId: l.letterId,
          pair: l.pairLabel,
          color: const Color(0xFF98A2B3),
          underlineColor: const Color(0xFFE5E7EB),
          enabled: false,
          selected: false,
          locked: true,
          phonicsAudioUrl: l.phonicsAudioUrl,
        );
    }
  }
}

class _LetterGrid extends StatelessWidget {
  const _LetterGrid({
    required this.items,
    required this.onLetterSelected,
  });

  final List<_LetterTileData> items;
  final Future<void> Function(int letterId) onLetterSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        return _LetterTile(
          data: it,
          onTap: () => onLetterSelected(it.letterId),
        );
      },
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.data,
    required this.onTap,
  });

  final _LetterTileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = data.selected ? const Color(0xFFBFF3ED) : const Color(0xFFF2F4F7);
    final tile = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: data.enabled ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.pair,
                      style: GoogleFonts.lexend(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: data.enabled ? data.color : const Color(0xFFD0D5DD),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: data.underlineColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              if (data.selected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF47495),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (data.locked) {
      return Opacity(opacity: 0.55, child: tile);
    }
    return tile;
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.headline,
    required this.goalLabel,
    required this.progress,
  });

  final String headline;
  final String goalLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = progress.clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 203, 124, 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF47495),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline.isEmpty ? 'Streak' : headline,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      goalLabel.isEmpty ? 'Keep learning to grow your streak!' : goalLabel,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        height: 1.25,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct <= 0 ? null : pct,
              minHeight: 6,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1C1C1C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlphabetLoungeScreenState extends State<AlphabetLoungeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AlphabetLoungeRepository _repo = AlphabetLoungeRepository();

  bool _loading = true;
  String? _errorMessage;
  AlphabetLoungePayload? _payload;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _repo.fetchLounge(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _payload = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
        _payload = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _loading = false;
        _payload = null;
      });
    }
  }

  Future<void> _openLetterFlow(int letterId) async {
    await Navigator.pushNamed(
      context,
      AppRouter.lettersplay,
      arguments: letterId,
    );
    if (!mounted) return;
    await _load(forceRefresh: true);
  }

  Future<void> _playUrl(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Could not play audio.'))),
      );
    }
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
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.dashboard,
                            (r) => false,
                          ),
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
                                _payload != null ? '${_payload!.coins}' : (_loading ? '…' : '—'),
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
              child: _buildBody(textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_loading && _payload == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _payload == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF475467)),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _load,
                child: Text(context.tr('Retry'), style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    final p = _payload!;

    return SingleChildScrollView(
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
                    Text(context.tr('Alphabet Lounge'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(21, 21, 21, 1),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(context.tr('Master the A-Z phonics through\nmusic and play.'),
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
                  AppAssets.exploreimage,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: const Color(0xFF43C2BD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Alphabet Lounge'),
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.black.withOpacity(.90),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(context.tr('Discover the magic of sounds. Every letter tells a story, every sound starts a quest.'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withOpacity(.70),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (p.morningSong != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      onTap: () {
                        final url = p.morningSong!.audioUrl;
                        if (url != null && url.isNotEmpty) {
                          _playUrl(url);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          border: Border.all(
                            color: Colors.black.withOpacity(.06),
                            width: 1,
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
                              p.morningSong!.title,
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
                ),
            ],
          ),
          SizedBox(height: 16),
          _StreakCard(
            headline: p.streakBanner.headline,
            goalLabel: p.streakBanner.goalLabel,
            progress: (p.streakBanner.goalProgressPct / 100).clamp(0.0, 1.0),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Phonics Explorer'),
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(context.tr('Tap a letter to hear its sound\nand see it dance!'),
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.25,
                        color: const Color.fromRGBO(28, 28, 28, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              _RoundActionButton(
                icon: Icons.volume_up_rounded,
                onTap: () {
                  for (final letter in p.letters) {
                    if (letter.status != 'locked' && (letter.phonicsAudioUrl ?? '').isNotEmpty) {
                      _playUrl(letter.phonicsAudioUrl!);
                      return;
                    }
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 14),
          _LetterGrid(
            items: p.letters.map(_LetterTileData.fromApiLetter).toList(),
            onLetterSelected: _openLetterFlow,
          ),
        ],
      ),
    );
  }
}