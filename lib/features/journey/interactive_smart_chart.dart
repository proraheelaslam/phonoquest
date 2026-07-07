// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phonoquest_signup_flow/features/journey/data/smart_chart_models.dart';
import 'package:phonoquest_signup_flow/features/journey/data/smart_chart_repository.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../core/l10n/app_language_controller.dart';

class InteractiveSmartChartScreen extends StatefulWidget {
  const InteractiveSmartChartScreen({super.key});

  @override
  State<InteractiveSmartChartScreen> createState() => _InteractiveSmartChartScreenState();
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




class _InteractiveSmartChartScreenState extends State<InteractiveSmartChartScreen> {
  final SmartChartRepository _repo = SmartChartRepository();
  final AudioPlayer _player = AudioPlayer();

  SmartChartPayload? _payload;
  bool _loading = true;
  String? _error;
  bool _playingAll = false;

  @override
  void initState() {
    super.initState();
    _loadSmartChart();
  }

  Future<void> _loadSmartChart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.fetchSmartChart();
      if (!mounted) return;
      setState(() {
        _payload = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? '$e' : 'Could not load smart chart data.';
        _loading = false;
      });
    }
  }

  Future<void> _playTile(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return;
    }

    try {
      await _player.stop();
      await _player.setUrl(url.trim());
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Could not play audio.'))),
      );
    }
  }

  Future<void> _playAll() async {
    final sections = _payload?.sections;
    if (sections == null || sections.isEmpty) return;

    setState(() {
      _playingAll = true;
    });

    final tiles = sections.expand((section) => section.tiles).where((tile) => tile.audioUrl != null && tile.audioUrl!.trim().isNotEmpty).toList();
    for (final tile in tiles) {
      if (!mounted) break;
      try {
        await _player.setUrl(tile.audioUrl!.trim());
        await _player.play();
        await _player.processingStateStream.firstWhere(
          (state) => state == ProcessingState.completed || state == ProcessingState.idle,
        );
      } catch (_) {
        // continue to next tile
      }
    }

    if (!mounted) return;
    setState(() {
      _playingAll = false;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Color _accentForTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'blend':
        return const Color(0xFFF47495);
      case 'vowel':
      default:
        return const Color(0xFFF7C653);
    }
  }

  int _crossAxisCountForTheme(String theme) {
    return theme.toLowerCase() == 'blend' ? 2 : 3;
  }

  double _childAspectRatioForTheme(String theme) {
    return theme.toLowerCase() == 'blend' ? 1.3 : 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                                    '${_payload?.coins ?? 0}',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    child: _loading
                        ? Center(child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: CircularProgressIndicator(),
                          ))
                        : _error != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Center(
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
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
                                              _payload?.title ?? 'Interactive Smart Chart',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700,
                                                color: const Color.fromRGBO(21, 21, 21, 1),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              _payload?.subtitle ??
                                                  'Explore the sounds of PhonoQuest. Tap\nany tile to hear the phoneme and see\nits magic pattern.',
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
                                          AppAssets.smartchartimage,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 18),
                                  ...?_payload?.sections.map((section) {
                                    final accent = _accentForTheme(section.theme);
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _SectionHeading(
                                          accent: accent,
                                          title: section.title,
                                        ),
                                        SizedBox(height: 14),
                                        _SoundGrid(
                                          items: section.tiles,
                                          crossAxisCount: _crossAxisCountForTheme(section.theme),
                                          childAspectRatio: _childAspectRatioForTheme(section.theme),
                                          accent: accent,
                                          onTileTap: (tile) => _playTile(tile.audioUrl),
                                        ),
                                        SizedBox(height: 18),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: Material(
                color: const Color(0xFFF47495),
                shape: const CircleBorder(),
                elevation: 10,
                shadowColor: const Color(0x29000000),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _playingAll ? null : _playAll,
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              AppAssets.playsoundimage,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _playingAll ? 'Playing' : 'Play All\nSounds',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
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
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.accent, required this.title});

  final Color accent;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 3,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(28, 28, 28, 1),
          ),
        ),
      ],
    );
  }
}

class _SoundGrid extends StatelessWidget {
  const _SoundGrid({
    required this.items,
    required this.crossAxisCount,
    required this.childAspectRatio,
    this.accent,
    this.onTileTap,
  });

  final List<SmartChartTile> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final Color? accent;
  final void Function(SmartChartTile tile)? onTileTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _SoundTileCard(
        data: items[index],
        accent: accent,
        onTap: onTileTap,
      ),
    );
  }
}

class _SoundTileCard extends StatelessWidget {
  const _SoundTileCard({required this.data, this.accent, this.onTap});

  final SmartChartTile data;
  final Color? accent;
  final void Function(SmartChartTile tile)? onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFFF7C653);
    return InkWell(
      onTap: onTap != null ? () => onTap!(data) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.code,
                maxLines: 1,
                style: GoogleFonts.lexend(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 6),
            Flexible(
              child: Text(
                data.exampleWord,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: const Color(0xFF98A2B3),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up_rounded,
                size: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}