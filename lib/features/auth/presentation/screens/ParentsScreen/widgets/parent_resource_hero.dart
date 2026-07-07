import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

/// Article-specific hero banner for parent resource featured cards.
class ParentResourceHero extends StatelessWidget {
  const ParentResourceHero({
    super.key,
    required this.resourceId,
    this.imageAssetKey,
    this.isVideo = false,
    this.height = 132,
  });

  final String resourceId;
  final String? imageAssetKey;
  final bool isVideo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: _buildHero(),
      ),
    );
  }

  Widget _buildHero() {
    switch (resourceId) {
      case 'reading_routine':
        return _bannerImage(AppAssets.parentResourceReadingRoutine);
      case 'dyslexia_strengths':
        return _illustrationHero(
          gradient: const [
            Color(0xFFFFF5F8),
            Color(0xFFFFE8F0),
            Color(0xFFFCE4EC),
          ],
          accent: const Color(0xFFF472B6),
          image: AppAssets.parentsinfoimage,
        );
      case 'decoding_strategies':
        return _illustrationHero(
          gradient: const [
            Color(0xFFFFF8F5),
            Color(0xFFFFEDE8),
            Color(0xFFFFE4E1),
          ],
          accent: const Color(0xFFFB7185),
          image: AppAssets.bookimage,
          icon: Icons.menu_book_rounded,
        );
      case 'bedtime_stories':
        return _illustrationHero(
          gradient: const [
            Color(0xFFF0F4FF),
            Color(0xFFE8EEFF),
            Color(0xFFDCE6FF),
          ],
          accent: const Color(0xFF6366F1),
          image: AppAssets.libraryimage,
          icon: Icons.nightlight_round,
        );
      default:
        final path = _resolveAssetPath(imageAssetKey);
        if (path == AppAssets.parentResourceReadingRoutine) {
          return _bannerImage(path);
        }
        return _illustrationHero(
          gradient: const [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
          accent: const Color(0xFF0075FF),
          image: path,
        );
    }
  }

  String _resolveAssetPath(String? key) {
    switch (key) {
      case 'parent_resource_reading_routine':
        return AppAssets.parentResourceReadingRoutine;
      case 'parentsinfoimage':
        return AppAssets.parentsinfoimage;
      case 'bookimage':
        return AppAssets.bookimage;
      case 'libraryimage':
        return AppAssets.libraryimage;
      case 'illustringimage':
        return AppAssets.illustringimage;
      case 'greatimage':
        return AppAssets.greatimage;
      default:
        return AppAssets.parentResourceReadingRoutine;
    }
  }

  Widget _bannerImage(String assetPath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        if (isVideo)
          Positioned(
            right: 10,
            top: 10,
            child: _videoBadge(),
          ),
      ],
    );
  }

  Widget _illustrationHero({
    required List<Color> gradient,
    required Color accent,
    required String image,
    IconData? icon,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: -10,
          child: Icon(
            icon ?? Icons.auto_awesome_rounded,
            size: 100,
            color: accent.withOpacity(0.12),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              height: height * 0.72,
            ),
          ),
        ),
        if (isVideo)
          Positioned(
            right: 10,
            top: 10,
            child: _videoBadge(),
          ),
      ],
    );
  }

  Widget _videoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'VIDEO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
