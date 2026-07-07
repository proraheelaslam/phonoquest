import 'package:flutter/material.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/theme/app_theme.dart';

class PaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String level;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  final String? summary;
  final List<String> features;
  final String? selectedImageAsset;
  final String? unselectedImageAsset;

  const PaceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.summary,
    this.features = const [],
    this.selectedImageAsset,
    this.unselectedImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = locked
        ? const Color(0xFFB8B8B8)
        : (selected ? AppTheme.pink : const Color(0xFFC7C7C7));
    final effectiveImageAsset = locked
        ? unselectedImageAsset
        : selected
            ? selectedImageAsset
            : unselectedImageAsset;

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          image: effectiveImageAsset == null
              ? null
              : DecorationImage(
                  image: AssetImage(effectiveImageAsset),
                  fit: BoxFit.cover,
                  colorFilter: locked
                      ? ColorFilter.mode(Colors.black.withOpacity(.25), BlendMode.darken)
                      : (selected ? null : ColorFilter.mode(Colors.white.withOpacity(.15), BlendMode.lighten)),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(selected ? .9 : .7),
                    ),
                  ),
                ),
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 10, color: Colors.black87),
                        const SizedBox(width: 4),
                        Text(context.tr('LOCKED'), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  )
                else if (selected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(context.tr('SELECTED'), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(.74))),
            SizedBox(height: 6),
            Text(level, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            if (summary != null && summary!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                summary!,
                style: TextStyle(fontSize: 11, height: 1.3, color: Colors.black.withOpacity(.65)),
              ),
            ],
            if (features.isNotEmpty) ...[
              SizedBox(height: 8),
              ...features.take(3).map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.black.withOpacity(.55)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(.7)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
