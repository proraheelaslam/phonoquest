// ignore_for_file: camel_case_types, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import 'settings_navigation_helper.dart';
import '../../../../core/auth/session_logout.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/l10n/app_language_controller.dart';

class appVersionScreen extends StatelessWidget {
  const appVersionScreen({super.key});

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
                          _versionCard(context),

                          SizedBox(height: 24),

                          _versionTitle('Current Version'),
                          SizedBox(height: 8),
                          _versionText(context.tr('You are using PhonoQuest version 1.0.0. This version includes learning activities, progress tracking, rewards, notifications, and account settings.'),
                          ),

                          SizedBox(height: 22),

                          _versionTitle('Latest Updates'),
                          SizedBox(height: 8),
                          _versionText(context.tr('• Improved app performance and loading speed\n• Updated learning activity experience\n• Enhanced notification screen design\n• Minor UI fixes and stability improvements'),
                          ),

                          SizedBox(height: 22),

                          _versionTitle('Update Information'),
                          SizedBox(height: 8),
                          _versionText(context.tr('Please keep your app updated to enjoy the latest features, security improvements, and a smoother learning experience.'),
                          ),

                          SizedBox(height: 22),

                          _versionTitle('Support'),
                          SizedBox(height: 8),
                          _versionText(context.tr('If you face any issue with this version, please contact support through the Help & Support section in settings.'),
                          ),

                          SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF53C8C1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRouter.login,
                                  (route) => false,
                                );
                                unawaited(logoutSession());
                              },
                              child: Text(
                                'Logout',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
            child: Text(context.tr('App Version'),
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

  Widget _versionCard(BuildContext context) {
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
            AppAssets.versionimage,
            width: 55,
            height: 55,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(
            'PhonoQuest',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 4),
          Text(context.tr('Version 1.0.0'),
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF414754),
            ),
          ),
        ],
      ),
    );
  }

  Widget _versionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1C1C),
      ),
    );
  }

  Widget _versionText(String text) {
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