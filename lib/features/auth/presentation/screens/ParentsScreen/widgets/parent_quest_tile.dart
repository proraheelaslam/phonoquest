import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/parent_status_models.dart';

class ParentQuestTile extends StatelessWidget {
  const ParentQuestTile({super.key, required this.quest});

  final RecentQuestItem quest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _iconBg(quest.icon),
            child: Icon(
              _icon(quest.icon),
              color: quest.reviewed
                  ? const Color.fromRGBO(220, 40, 60, 1)
                  : Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.timeLabel,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: const Color.fromRGBO(113, 119, 134, 1),
                  ),
                ),
                Text(
                  quest.title,
                  style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(quest.subtitle, style: GoogleFonts.lexend(fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: quest.reviewed
                  ? const Color.fromRGBO(230, 232, 238, 1)
                  : const Color.fromRGBO(218, 246, 225, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              quest.badge,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: quest.reviewed
                    ? const Color.fromRGBO(113, 119, 134, 1)
                    : const Color.fromRGBO(0, 150, 75, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(String key) {
    switch (key) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'headphones':
        return Icons.headphones_rounded;
      case 'refresh':
        return Icons.refresh_rounded;
      case 'star':
      default:
        return Icons.star_rounded;
    }
  }

  static Color _iconBg(String key) {
    switch (key) {
      case 'book':
        return const Color.fromRGBO(0, 117, 255, 1);
      case 'headphones':
        return const Color.fromRGBO(224, 224, 224, 1);
      case 'refresh':
        return const Color.fromRGBO(255, 214, 218, 1);
      case 'star':
      default:
        return const Color.fromRGBO(255, 184, 0, 1);
    }
  }
}
