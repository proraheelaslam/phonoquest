import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/core/media/network_media_image.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

/// Maps alphabet example words to bundled illustration assets.
String? alphabetWordAssetPath(String word) {
  final slug = word.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (slug.isEmpty) return null;

  const paths = <String, String>{
    'apple': AppAssets.appleimage,
    'apples': AppAssets.applesimage,
    'ant': AppAssets.bugimage,
    'ball': AppAssets.playfullimage,
    'bat': AppAssets.playimage,
    'boat': AppAssets.shipimage,
    'bus': AppAssets.tabletimage,
    'cat': AppAssets.catimage,
    'cup': AppAssets.redappleimage,
    'dog': AppAssets.dogimage,
    'dogs': AppAssets.dogsimage,
    'duck': AppAssets.fishimage,
    'egg': AppAssets.babyimage,
    'elf': AppAssets.leoimage,
    'fish': AppAssets.fishimage,
    'fan': AppAssets.waveimage,
    'goat': AppAssets.monkeyfaceimage,
    'gift': AppAssets.rewardimage,
    'hat': AppAssets.bookimage,
    'hen': AppAssets.egleimage,
    'igloo': AppAssets.sunnyimage,
    'ink': AppAssets.bookimage,
    'jam': AppAssets.redappleimage,
    'jet': AppAssets.arrowimage,
    'kite': AppAssets.starimage,
    'key': AppAssets.goalimage,
    'lion': AppAssets.monkeyfaceimage,
    'leaf': AppAssets.forestimage,
    'map': AppAssets.exploreimage,
    'moon': AppAssets.sunnyimage,
    'nest': AppAssets.homeimage,
    'net': AppAssets.fishimage,
    'ox': AppAssets.dogimage,
    'owl': AppAssets.egleimage,
    'pig': AppAssets.babyimage,
    'pen': AppAssets.bookimage,
    'queen': AppAssets.starimage,
    'quilt': AppAssets.sockimage,
    'rat': AppAssets.bugimage,
    'ring': AppAssets.goalimage,
    'sun': AppAssets.sunimage,
    'star': AppAssets.starsimage,
    'top': AppAssets.playimage,
    'tent': AppAssets.homeimage,
    'umbrella': AppAssets.sunnyimage,
    'up': AppAssets.arrowimage,
    'van': AppAssets.tabletimage,
    'vest': AppAssets.goalimage,
    'web': AppAssets.exploreimage,
    'wig': AppAssets.profileimage,
    'box': AppAssets.bookimage,
    'fox': AppAssets.dogimage,
    'yak': AppAssets.dogimage,
    'yarn': AppAssets.sockimage,
    'zip': AppAssets.arrowimage,
    'zoo': AppAssets.monkeyfaceimage,
  };

  return paths[slug];
}

class AlphabetWordThumbnail extends StatelessWidget {
  const AlphabetWordThumbnail({
    super.key,
    required this.word,
    this.networkUrl,
    this.size = 36,
  });

  final String word;
  final String? networkUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = alphabetWordAssetPath(word);
    final trimmedUrl = networkUrl?.trim() ?? '';
    final hasNetwork = trimmedUrl.isNotEmpty;

    Widget fallback() {
      if (asset != null) {
        return Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _LetterFallback(word: word, size: size),
        );
      }
      return _LetterFallback(word: word, size: size);
    }

    if (!hasNetwork) {
      return fallback();
    }

    return NetworkMediaImage(
      url: trimmedUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      borderRadius: BorderRadius.circular(8),
      fallback: fallback(),
    );
  }
}

class _LetterFallback extends StatelessWidget {
  const _LetterFallback({required this.word, required this.size});

  final String word;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = word.trim().isNotEmpty ? word.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: GoogleFonts.lexend(
          fontSize: size * 0.48,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0066CC),
        ),
      ),
    );
  }
}
