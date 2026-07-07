// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/login_validated_field.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../signup/presentation/registration_validators.dart';
import '../../data/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _submitting = true);
    try {
      await _authRepo.requestPasswordReset(email: _emailController.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Something went wrong. Please try again.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            Positioned.fill(
              child: SvgPicture.asset(AppAssets.signUpBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.asset(
                      AppAssets.loginbackgroundimage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
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
                              child: Column(
                                children: [
                                  Text(
                                    context.tr('Forgot Password?'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: const Color.fromRGBO(2, 2, 2, 1),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    _sent
                                        ? context.tr(
                                            'If an account exists for that email, password reset instructions were sent.',
                                          )
                                        : context.tr(
                                            'Enter your email and we will send you a link to reset your password.',
                                          ),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: const Color.fromRGBO(65, 71, 84, 1),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  if (!_sent) ...[
                                    LoginValidatedField(
                                      controller: _emailController,
                                      hintText: context.tr('Email address'),
                                      prefixIcon: Image.asset(AppAssets.smsimage),
                                      obscureText: false,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _submit(),
                                      validator: RegistrationValidators.email,
                                    ),
                                    SizedBox(height: 24),
                                    PrimaryButton(
                                      label: context.tr('Send reset link'),
                                      onTap: _submit,
                                      isBusy: _submitting,
                                    ),
                                  ],
                                  SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacementNamed(
                                      context,
                                      AppRouter.login,
                                    ),
                                    child: Text(
                                      context.tr('Back to login'),
                                      style: GoogleFonts.lexend(
                                        fontWeight: FontWeight.w700,
                                        color: const Color.fromRGBO(83, 200, 193, 1),
                                      ),
                                    ),
                                  ),
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
}
