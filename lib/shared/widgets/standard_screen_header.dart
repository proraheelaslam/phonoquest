import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_assets.dart';

/// Centered title + standard back control (matches Account Details / Change Password).
class StandardScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const StandardScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  AppAssets.backimage,
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(26, 28, 28, 1),
            ),
          ),
        ],
      ),
    );
  }
}
