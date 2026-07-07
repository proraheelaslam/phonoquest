import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

class ModuleUiHelper {
  static String imageForCode(String code) {
    switch (code) {
      case 'blend_forest':
        return AppAssets.journeyimage;
      case 'vowel_learning':
        return AppAssets.vowelsimage;
      case 'alphabet_lounge':
        return AppAssets.exploreimage;
      case 'phonicscards':
      case 'phonics_cards':
        return AppAssets.exploreimage;
      default:
        return AppAssets.exploreimage;
    }
  }

  static Color previewColorForCode(String code) {
    switch (code) {
      case 'blend_forest':
        return const Color(0xFF0B5ED7);
      case 'vowel_learning':
        return const Color(0xFFF47495);
      default:
        return const Color(0xFFF47495);
    }
  }

  static String initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Color scoreColor(int score) {
    if (score >= 80) return const Color(0xFF2E7D32);
    if (score >= 60) return const Color(0xFF1A1C1C);
    return const Color(0xFFC03535);
  }

  static String assignedDaysLabel(int days) {
    if (days <= 0) return 'Assigned today';
    if (days == 1) return 'Assigned: 1 day ago';
    return 'Assigned: $days days ago';
  }
}
