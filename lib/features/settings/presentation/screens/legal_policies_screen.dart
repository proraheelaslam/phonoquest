// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_language_controller.dart';
import '../../domain/legal_links.dart';
import 'settings_navigation_helper.dart';

Future<void> openLegalWebUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Invalid link.'))),
    );
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Could not open link.'))),
    );
  }
}

/// Hub screen: Terms & conditions + Privacy policy → each opens a web page.
class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final returnRoute = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => navigateBackToSettings(
                        context,
                        returnRoute: returnRoute is String ? returnRoute : null,
                      ),
                      icon: Image.asset(AppAssets.backimage, width: 22, height: 22),
                    ),
                    Text(
                      context.tr('Terms & policies'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < legalPolicyMenuItems.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFE4E7EC),
                        ),
                      InkWell(
                        onTap: () => openLegalWebUrl(context, legalPolicyMenuItems[i].url),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.tr(legalPolicyMenuItems[i].titleKey),
                                  style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF98A2B3),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
