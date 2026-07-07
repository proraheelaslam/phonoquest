// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class giveFeedbackScreen extends StatelessWidget {
  const giveFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.dashboardimage,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),

                  SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _feedbackCard(context),

                          SizedBox(height: 24),

                          _feedbackTitle('Share Your Experience'),

                          SizedBox(height: 8),

                          _feedbackText(context.tr('Your feedback helps us improve the app experience, learning activities, rewards, and overall performance.'),
                          ),

                          SizedBox(height: 22),

                          _feedbackTitle('What can you report?'),

                          SizedBox(height: 8),

                          _feedbackText(context.tr('• App bugs or crashes\n• Lesson or sound issues\n• Login or account problems\n• Suggestions for new features\n• UI/UX improvement ideas'),
                          ),

                          SizedBox(height: 22),

                          _feedbackTitle('How to send feedback'),

                          SizedBox(height: 8),

                          _feedbackText(context.tr('Please describe your issue or suggestion clearly. Include the screen name, what happened, and what you expected instead.'),
                          ),

                          SizedBox(height: 22),

                          _feedbackTitle('Response Time'),

                          SizedBox(height: 8),

                          _feedbackText(context.tr('Our support team reviews feedback regularly and uses it to improve future app updates.'),
                          ),

                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: DashboardBottomNavBar(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  AppAssets.backimage,
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),

          Center(
            child: Text(context.tr('Give Feedback'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.feedbackimage,
            width: 55,
            height: 55,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(context.tr('We Value Your Feedback'),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(context.tr('Help us make PhonoQuest better for every learner.'),
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF414754),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1C1C),
      ),
    );
  }

  Widget _feedbackText(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: const Color(0xFF414754),
      ),
    );
  }
}