// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types, unused_import

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class classCreatedScreen extends StatefulWidget {
  const classCreatedScreen({super.key});

  @override
  State<classCreatedScreen> createState() => _classCreatedScreenState();
}

class _classCreatedScreenState extends State<classCreatedScreen> {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,

                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.journeyimage,
                      width: 135,
                      height: 135,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 22),
                  Text(context.tr('Class Created!'),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(context.tr('Your students are ready for their phonics\nadventure.'),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF717786),
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRouter.teachersclasses);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43C2BD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.tr('GO TO CLASS DASHBOARD'),
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1C1C),
                              letterSpacing: .6,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1A1C1C), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

