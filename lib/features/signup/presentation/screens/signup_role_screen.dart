// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 👈 important
import '../../../../core/router/app_router.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/role_tab.dart';
import '../../../../core/l10n/app_language_controller.dart';

class SignupRoleScreen extends StatefulWidget {
  const SignupRoleScreen({super.key});

  @override
  State<SignupRoleScreen> createState() => _SignupRoleScreenState();
}

class _SignupRoleScreenState extends State<SignupRoleScreen> {
  String selectedRole = 'Student';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // 🔹 Background SVG Image
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.signUpBackground, // 👈 make sure path correct
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Your UI
            SafeArea(
              child: PhonoShell(
                stepLabel: '',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: SingleChildScrollView(
                    child: Column(
                    children: [
                      if (selectedRole == 'Teacher')
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 245, 230, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(context.tr('STEP 1 OF 4'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Color.fromRGBO(248, 118, 146, 1),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(context.tr('How will you be\nusing PhonoQuest?'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24, // 👈 apni size
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(context.tr('Choose the role that best describes you to tailor your learning journey and experience.'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 25),
               SizedBox(
                    height: 260,
                    child: Center(
                      child: Image.asset(
                        selectedRole == 'Teacher'
                            ? AppAssets.teacheremojiimage
                            : selectedRole == 'Parent'
                                ? AppAssets.parentsinfoimage
                                : AppAssets.emojiimage,
                        width: 260,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                      SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            RoleTab(label: context.tr('Student'), active: selectedRole == 'Student', onTap: () => setState(() => selectedRole = 'Student')),
                            RoleTab(label: context.tr('Teacher'), active: selectedRole == 'Teacher', onTap: () => setState(() => selectedRole = 'Teacher')),
                            RoleTab(label: context.tr('Parent'), active: selectedRole == 'Parent', onTap: () => setState(() => selectedRole = 'Parent')),
                          ],
                        ),
                      ),
                      SizedBox(height: 28),
                      PrimaryButton(
                        label: context.tr('CONTINUE'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          selectedRole == 'Teacher'
                              ? AppRouter.personalinfo
                              : selectedRole == 'Parent'
                                  ? AppRouter.parentspersonalinfo
                                  : AppRouter.signupDetails,
                        ),
                      ),
                      SizedBox(height: 30),
                    RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black.withOpacity(.48),
                                  ),
                              children: [
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: 'Log In',
                                  style: const TextStyle(
                                    color: Color(0xFFF47495),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // 👇 yahan apna action likho
                                      print("Log In clicked");

                                      // Example navigation:
                                       Navigator.pushNamed(context, AppRouter.login, arguments: selectedRole);
                                    },
                                ),
                              ],
                            ),
                          ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _badge('COPPA COMPLIANT', Icons.verified_user_outlined),
                              SizedBox(width: 26),
                              _badge('PARENT APPROVED', Icons.family_restroom_outlined),
                            ],
                          ),
                          SizedBox(height: 8),
                          _badge('RESEARCH BASED', Icons.shield_outlined),
                        ],
                      ),
                      SizedBox(height: 14),
                    ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(.45)),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(.45), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}