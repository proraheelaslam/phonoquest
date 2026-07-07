// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class accessbilityScreen extends StatefulWidget {
  const accessbilityScreen({super.key});

  @override
  State<accessbilityScreen> createState() => _accessbilityScreenState();
}

class _accessbilityScreenState extends State<accessbilityScreen> {
  bool darkMode = false;
  bool highContrast = false;
  bool readingAid = true;
  bool reduceMotion = false;
  double fontSize = 1;

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
                children: [
                  _header(context),
                  SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _topCard(),

                          SizedBox(height: 18),

                          _switchTile(
                            title: context.tr('Dark Theme'),
                            subtitle: context.tr('Use darker colors for comfortable reading.'),
                            value: darkMode,
                            onChanged: (v) => setState(() => darkMode = v),
                          ),

                          _switchTile(
                            title: context.tr('High Contrast'),
                            subtitle: context.tr('Improve visibility with stronger colors.'),
                            value: highContrast,
                            onChanged: (v) => setState(() => highContrast = v),
                          ),

                          _switchTile(
                            title: context.tr('Reading Aids'),
                            subtitle: context.tr('Enable helpful spacing and reading support.'),
                            value: readingAid,
                            onChanged: (v) => setState(() => readingAid = v),
                          ),

                          _switchTile(
                            title: context.tr('Reduce Animations'),
                            subtitle: context.tr('Limit motion effects across the app.'),
                            value: reduceMotion,
                            onChanged: (v) => setState(() => reduceMotion = v),
                          ),

                          SizedBox(height: 14),

                          _fontSizeCard(),

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
            child: Text(
              'Accessibility',
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

  Widget _topCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.accessibilityimage,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(context.tr('Make Learning Easier'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(context.tr('Customize theme, text size, contrast and reading support for a better experience.'),
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

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    height: 1.4,
                    color: const Color(0xFF414754),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF53C8C1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _fontSizeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('Font Size'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 4),
          Text(context.tr('Adjust app text size for easier reading.'),
            style: GoogleFonts.lexend(
              fontSize: 11,
              color: const Color(0xFF414754),
            ),
          ),
          Slider(
            value: fontSize,
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: const Color(0xFF53C8C1),
            label: fontSize == 0
                ? 'Small'
                : fontSize == 1
                    ? 'Medium'
                    : 'Large',
            onChanged: (value) {
              setState(() {
                fontSize = value;
              });
            },
          ),
        ],
      ),
    );
  }
}