// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class termspolicyScreen extends StatelessWidget {
  const termspolicyScreen({super.key});

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

                          _termsTitle('1. Acceptance of Terms'),

                          SizedBox(height: 8),

                          _termsText(context.tr('By using this application, you agree to comply with and be bound by these Terms & Conditions. If you do not agree, please discontinue use of the app.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('2. User Accounts'),

                          SizedBox(height: 8),

                          _termsText(context.tr('Users are responsible for maintaining the confidentiality of their login credentials and account activities.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('3. Learning Content'),

                          SizedBox(height: 8),

                          _termsText(context.tr('All lessons, quizzes, activities, and educational resources provided in the application are intended for personal learning purposes only.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('4. Privacy & Data'),

                          SizedBox(height: 8),

                          _termsText(context.tr('We may collect limited information to improve user experience, monitor performance, and personalize educational content.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('5. Prohibited Activities'),

                          SizedBox(height: 8),

                          _termsText(context.tr('Users must not misuse the platform, attempt unauthorized access, copy protected content, or interfere with app functionality.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('6. Updates & Changes'),

                          SizedBox(height: 8),

                          _termsText(context.tr('We reserve the right to update features, modify policies, or change application content at any time without prior notice.'),
                          ),

                          SizedBox(height: 22),

                          _termsTitle('7. Contact & Support'),

                          SizedBox(height: 8),

                          _termsText(context.tr('If you have any questions regarding these Terms & Conditions, please contact our support team through the application settings.'),
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

          // Back Button
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

          // Center Title
          Center(
            child: Text(context.tr('Terms & Privacy Policy'),
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

  Widget _termsTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1C1C),
      ),
    );
  }

  Widget _termsText(String text) {
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