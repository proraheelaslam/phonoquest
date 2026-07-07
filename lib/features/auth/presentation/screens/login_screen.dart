// ignore_for_file: unused_element, prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/auth_flow_navigation.dart';
import '../../data/auth_repository.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/login_validated_field.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../signup/presentation/registration_validators.dart';
import '../../../../core/l10n/app_language_controller.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;

  const LoginScreen({super.key, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedRole = 'Student';
  bool obscurePassword = true;
  bool _submitting = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final role = widget.initialRole;
    if (role != null && (role == 'Student' || role == 'Teacher' || role == 'Parent')) {
      selectedRole = role;
    }
  }

  String _loginBackgroundForRole(String role) {
    switch (role) {
      case 'Student':
        return AppAssets.loginbackgroundimage;
      case 'Teacher':
        return AppAssets.teacherbackgroundimage;
      case 'Parent':
        return AppAssets.parentsbackgroundimage;
      default:
        return AppAssets.loginbackgroundimage;
    }
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _submitting = true);
    try {
      final session = await AuthRepository().login(
        email: email,
        password: password,
        type: loginTypeFromRoleLabel(selectedRole),
      );
      if (!mounted) return;
      ApiClient.clearRequestCache();
      navigateAfterAuth(context, session);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isEmailNotVerified) {
        navigateToVerifyEmail(context, email: email);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Something went wrong. Please try again.')), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            // 🔹 Background SVG
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.signUpBackground,
                fit: BoxFit.cover,
              ),
            ),

            // 🔥 MAIN LAYOUT FIXED
            SafeArea(
              top: false,
              child: Column(
                children: [
                  // 🔥 TOP IMAGE (OVERLAP FIXED)
                  SizedBox(
                    height: 340,
                    width: double.infinity,
                    child: Image.asset(
                      _loginBackgroundForRole(selectedRole),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),

                  // 🔥 CONTENT BELOW IMAGE
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -25),
                      child: PhonoShell(
                      stepLabel: '',
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 15),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 0),

                                Text(context.tr('Let’s Get You\nSigned In!'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800, // ExtraBold
                                    height: 1.05,
                                    color: const Color.fromRGBO(2, 2, 2, 1),
                                  ),
                                ),

                                SizedBox(height: 30),

                                _roleDropdown(context),

                                SizedBox(height: 17),

                                LoginValidatedField(
                                  controller: _emailController,
                                  hintText: context.tr('Email address'),
                                  prefixIcon: Image.asset(AppAssets.smsimage),
                                  obscureText: false,
                                  textInputAction: TextInputAction.next,
                                  validator: RegistrationValidators.email,
                                ),

                                SizedBox(height: 17),

                                LoginValidatedField(
                                  controller: _passwordController,
                                  hintText: context.tr('Password'),
                                  prefixIcon: Image.asset(AppAssets.passwordcheckimage),
                                  obscureText: obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  validator: RegistrationValidators.loginPassword,
                                  suffix: IconButton(
                                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    icon: Icon(
                                      obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: const Color.fromRGBO(83, 200, 193, 1),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 5),

                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRouter.forgotPassword,
                                  ),
                                  child: Text(context.tr('Forgot Password?'),
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromRGBO(83, 200, 193, 1),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 28),

                                PrimaryButton(
                                  label: context.tr('LOGIN'),
                                  onTap: _login,
                                  isBusy: _submitting,
                                ),

                                SizedBox(height: 24),

                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color.fromRGBO(65, 71, 84, 1),
                                    ),
                                    children: [
                                      TextSpan(text: context.tr("You don’t have an account yet? ")),
                                      TextSpan(
                                        text: context.tr('Sign Up'),
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(26, 28, 28, 1),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(context, AppRouter.signupRole);
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  // ===== SAME FUNCTIONS (NO CHANGE) =====

  Widget _roleDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF67D4CF), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            DropdownMenuItem(value: 'Student', child: Text(context.tr('Student'))),
            DropdownMenuItem(value: 'Parent', child: Text(context.tr('Parent'))),
            DropdownMenuItem(value: 'Teacher', child: Text(context.tr('Teacher'))),
          ],
          selectedItemBuilder: (context) {
            return ['Student', 'Parent', 'Teacher']
                .map(
                  (role) => Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          AppAssets.studentsimage,
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        context.tr(role),
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromRGBO(26, 28, 28, 1),
                        ),
                      ),
                    ],
                  ),
                )
                .toList();
          },
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedRole = value);
          },
        ),
      ),
    );
  }

}