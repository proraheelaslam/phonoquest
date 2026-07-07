// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class helpSupportScreen extends StatelessWidget {
  const helpSupportScreen({super.key});

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
                          _supportTitle('1. Learning Help'),

                          SizedBox(height: 8),

                          _supportText(context.tr('If you are having trouble with lessons, sounds, quizzes, or learning activities, please restart the activity and try again. Make sure your internet connection is stable.'),
                          ),

                          SizedBox(height: 22),

                          _supportTitle('2. Login & Account'),

                          SizedBox(height: 8),

                          _supportText(context.tr('If you cannot log in, check your email and password carefully. You can also use the forgot password option to reset your account access.'),
                          ),

                          SizedBox(height: 22),

                          _supportTitle('3. Progress & Rewards'),

                          SizedBox(height: 8),

                          _supportText(context.tr('Your progress, badges, levels, and streaks are updated automatically after completing learning activities. If progress does not update, close and reopen the app.'),
                          ),

                          SizedBox(height: 22),

                          _supportTitle('4. Sound & Audio Issues'),

                          SizedBox(height: 8),

                          _supportText(context.tr('Please check your device volume, app sound settings, and permissions. For best results, use headphones while practicing phonics sounds.'),
                          ),

                          SizedBox(height: 22),

                          _supportTitle('5. App Performance'),

                          SizedBox(height: 8),

                          _supportText(context.tr('If the app feels slow, clear background apps, check your internet connection, and make sure you are using the latest version of the application.'),
                          ),

                          SizedBox(height: 22),

                          _supportTitle('6. Contact Support'),

                          SizedBox(height: 8),

                          _supportText(context.tr('For further help, contact our support team through the feedback or support option in the settings screen. Please include your issue details clearly.'),
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
            child: Text(context.tr('Help & Support'),
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

  Widget _supportTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1C1C),
      ),
    );
  }

  Widget _supportText(String text) {
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