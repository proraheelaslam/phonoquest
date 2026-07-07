// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/l10n/app_locale.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'settings_navigation_helper.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';

class languageScreen extends StatefulWidget {
  const languageScreen({super.key});

  @override
  State<languageScreen> createState() => _languageScreenState();
}

class _languageScreenState extends State<languageScreen> {
  final _language = AppLanguageController.instance;
  String _selectedCode = AppLocale.en;
  String? _settingsReturnRoute;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = _language.code;
    _language.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _selectedCode = _language.code;
    });
  }

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

  Future<void> _saveLanguage() async {
    if (_saving) return;
    final token = await AuthTokenStorage.instance.readAccessToken();
    setState(() => _saving = true);
    try {
      if (token != null) {
        await _language.saveToServer(_selectedCode);
      } else {
        await _language.applyCode(_selectedCode);
      }
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.languageUpdated)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.couldNotUpdateLanguage),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
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
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              child: Column(
                children: [
                  _header(context, t.languageScreenTitle),
                  SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _topCard(t),
                          SizedBox(height: 18),
                          _languageTile(
                            title: AppLocale.displayNameLocalized(AppLocale.en, _language.code),
                            subtitle: AppLocale.subtitle(AppLocale.en),
                            value: AppLocale.en,
                          ),
                          _languageTile(
                            title: AppLocale.displayNameLocalized(AppLocale.es, _language.code),
                            subtitle: AppLocale.subtitle(AppLocale.es),
                            value: AppLocale.es,
                          ),
                          SizedBox(height: 10),
                          Text(
                            t.perUserLanguageNote,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              height: 1.4,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 14),
                          PrimaryButton(
                            label: _saving ? t.savingLanguage : t.saveLanguage,
                            isBusy: _saving,
                            onTap: _dirty ? _saveLanguage : null,
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

  Widget _header(BuildContext context, String title) {
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
              title,
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

  Widget _topCard(AppTranslations t) {
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
            AppAssets.languageimage,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(
            t.chooseAppLanguage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(
            t.chooseAppLanguageHint,
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

  Widget _languageTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = _selectedCode == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCode = value;
          _dirty = value != _language.code;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA).withOpacity(.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF53C8C1) : Colors.transparent,
            width: 1.5,
          ),
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
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF53C8C1) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
