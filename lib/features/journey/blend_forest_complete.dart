// ignore_for_file: unused_import, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../core/l10n/app_language_controller.dart';


class blendForesrCompleteScreen extends StatelessWidget {
  const blendForesrCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF47495),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAssets.backIcon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Color.fromRGBO(202, 205, 219, 1),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 6),
                      const _QuestBadge(),
                      SizedBox(height: 18),
                      Text(context.tr('Quest\nComplete!'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          color: const Color.fromRGBO(0, 102, 204, 1),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(context.tr('You are officially a Forest\nExplorer!'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(height: 18),
                      const _BlendsMasteredCard(
                        blends: ['SH', 'CH', 'TH'],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 54,
                        child: Material(
                          color: const Color(0xFFF47495),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRouter.blendforest,
                                (_) => false,
                              );
                            },
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(context.tr('Next Quest'),
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color.fromRGBO(28, 28, 28, 1),
                                    ),
                                  ),
                                  SizedBox(width: 10),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestBadge extends StatelessWidget {
  const _QuestBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFAC515),
        boxShadow: [
          BoxShadow(
            color: Color(0x33FAC515),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          size: 52,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BlendsMasteredCard extends StatelessWidget {
  const _BlendsMasteredCard({required this.blends});

  final List<String> blends;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.blendsmateredimage,
                  width: 18,
                  height: 18,
                ),
                SizedBox(width: 8),
                Text(context.tr('Blends Mastered')),
              ],
            ),
                    SizedBox(height: 14),
          for (int i = 0; i < blends.length; i++) ...[
            _BlendMasteredRow(label: blends[i]),
            if (i != blends.length - 1) SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BlendMasteredRow extends StatelessWidget {
  const _BlendMasteredRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color.fromRGBO(0, 102, 204, 1),
            ),
          ),
          const Spacer(),
         SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              AppAssets.tickimage,
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }
}


