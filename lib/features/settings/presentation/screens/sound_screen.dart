// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_language_controller.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import 'settings_navigation_helper.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';

class SoundAudioScreen extends StatefulWidget {
  const SoundAudioScreen({super.key});

  @override
  State<SoundAudioScreen> createState() => _SoundAudioScreenState();
}

class _SoundAudioScreenState extends State<SoundAudioScreen> {
  bool appSounds = true;
  bool voicePronunciation = true;
  bool backgroundMusic = false;
  bool muteAll = false;

  double effectsVolume = 0.7;
  double musicVolume = 0.4;
  String? _settingsReturnRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.startsWith('/')) {
      _settingsReturnRoute = args;
    }
  }

  bool get _showStudentBottomNav =>
      _settingsReturnRoute == null || _settingsReturnRoute == AppRouter.settings;

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
                        children: [
                          _topCard(),
                          SizedBox(height: 18),

                          _switchTile(
                            title: context.t.tr('sound.app_sounds'),
                            subtitle: context.t.tr('sound.app_sounds_sub'),
                            value: appSounds,
                            onChanged: (v) => setState(() => appSounds = v),
                          ),

                          _switchTile(
                            title: context.t.tr('sound.voice'),
                            subtitle: context.t.tr('sound.voice_sub'),
                            value: voicePronunciation,
                            onChanged: (v) =>
                                setState(() => voicePronunciation = v),
                          ),

                          _switchTile(
                            title: context.t.tr('sound.music'),
                            subtitle: context.t.tr('sound.music_sub'),
                            value: backgroundMusic,
                            onChanged: (v) =>
                                setState(() => backgroundMusic = v),
                          ),

                          _switchTile(
                            title: context.t.tr('sound.mute_all'),
                            subtitle: context.t.tr('sound.mute_all_sub'),
                            value: muteAll,
                            onChanged: (v) => setState(() => muteAll = v),
                          ),

                          SizedBox(height: 14),

                          _sliderCard(
                            title: 'Sound Effects Volume',
                            subtitle: 'Adjust button clicks and reward sounds.',
                            value: effectsVolume,
                            onChanged: muteAll
                                ? null
                                : (v) => setState(() => effectsVolume = v),
                          ),

                          SizedBox(height: 12),

                          _sliderCard(
                            title: 'Music Volume',
                            subtitle: 'Adjust background music volume.',
                            value: musicVolume,
                            onChanged: muteAll
                                ? null
                                : (v) => setState(() => musicVolume = v),
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
      bottomNavigationBar: _showStudentBottomNav
          ? DashboardBottomNavBar(
              currentIndex: 3,
              onTap: (index) {},
            )
          : null,
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
                onTap: () async => navigateBackToSettings(
                  context,
                  returnRoute: _settingsReturnRoute,
                ),
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
              context.t.tr('sound.title'),
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
            AppAssets.soundimage,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(
            'Control App Audio',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Manage voice, music, and sound effects for a better learning experience.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 12,
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

  Widget _sliderCard({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double>? onChanged,
  }) {
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
              color: const Color(0xFF414754),
            ),
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            activeColor: const Color(0xFF53C8C1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}