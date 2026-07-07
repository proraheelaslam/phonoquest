// ignore_for_file: unused_import, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../core/l10n/app_language_controller.dart';


class viewLearningCompleteScreen extends StatelessWidget {
  const viewLearningCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // lessonKey not required for this view; omit to avoid unused-variable warning

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
                  SizedBox(height: 14),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color.fromRGBO(202, 205, 219, 1),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _QuestBadge(),
                              SizedBox(height: 18),
                              Text(context.tr('Great job!'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                  color: const Color.fromRGBO(26, 28, 28, 1),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(context.tr('You’ve completed the vowel challenge. Keep going to master more sounds!'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                              SizedBox(height: 24),
                              SizedBox(
                                height: 56,
                                child: Material(
                                  color: const Color(0xFFF47495),
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRouter.vowelslearning,
                                        (route) => false,
                                      );
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(context.tr('Next Adventure'),
                                            style: GoogleFonts.lexend(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: const Color.fromRGBO(28, 28, 28, 1),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// subtitle removed per UX request

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

// Progress section removed per UX request


