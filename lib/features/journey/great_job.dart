// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../core/l10n/app_language_controller.dart';

class greatJobScreen extends StatelessWidget {
  const greatJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(context.tr('Phonics Cards'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromRGBO(26, 28, 28, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          _GreatJobBadge(),
                          SizedBox(height: 0),
                          Text(context.tr('Great job!'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: const Color.fromRGBO(26, 28, 28, 1),
                            ),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                              children: [
                                TextSpan(text: context.tr("You've mastered ")),
                                TextSpan(
                                  text: '50 sounds',
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color.fromRGBO(0, 102, 204, 1),
                                  ),
                                ),
                                TextSpan(text: context.tr(' today!')),
                              ],
                            ),
                          ),
                          SizedBox(height: 18),
                          _SoundsConqueredCard(),
                          SizedBox(height: 30),
                          SizedBox(
                            width: 290,
                            height: 52,
                            child: Material(
                              color: const Color(0xFFF47495),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {},
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(context.tr('Continue to Next Level'),
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: const Color.fromRGBO(28, 28, 28, 1),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Color.fromRGBO(28, 28, 28, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          InkWell(
                            onTap: () {},
                            child: Text(context.tr('Review Session'),
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(0, 102, 204, 1),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
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

class _GreatJobBadge extends StatelessWidget {
  const _GreatJobBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Image.asset(
        AppAssets.greatimage, // 👈 apni image ka path
        fit: BoxFit.contain,
      ),
    );
  }
}

class _SoundsConqueredCard extends StatelessWidget {
  const _SoundsConqueredCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(247, 205, 135, 1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                Text(context.tr('SOUNDS CONQUERED'),
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _ConqueredChip(label: 'A'),
                    SizedBox(width: 14),
                    _ConqueredChip(label: 'B'),
                    SizedBox(width: 14),
                    _ConqueredChip(label: 'C'),
                  ],
                ),
                SizedBox(height: 16),
                const _ConqueredChip(
                  label: 'SH',
                  active: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConqueredChip extends StatelessWidget {
  const _ConqueredChip({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFB6D3FF) : const Color(0xFFF2F4F7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color.fromRGBO(26, 28, 28, 1),
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFAC515),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}


