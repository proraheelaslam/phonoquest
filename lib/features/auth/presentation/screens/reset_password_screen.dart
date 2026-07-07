// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_query.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/login_validated_field.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../signup/presentation/registration_validators.dart';
import '../../data/auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  late String? _token;

  @override
  void initState() {
    super.initState();
    _token = widget.initialToken ?? RouteQuery.parameter('token');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? value) {
    return RegistrationValidators.confirmPassword(value, _passwordController.text);
  }

  Future<void> _submit() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Reset link is invalid or expired.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _submitting = true);
    try {
      await _authRepo.resetPassword(
        token: token,
        newPassword: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Password reset successfully. You can sign in with your new password.'),
          ),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
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
    final hasToken = _token != null && _token!.isNotEmpty;
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
                                    context.tr('Reset Password'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    hasToken
                                        ? context.tr('Create a new password to keep your account safe and secure.')
                                        : context.tr('Reset link is invalid or expired.'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(fontSize: 13, height: 1.5),
                                  ),
                                  if (hasToken) ...[
                                    SizedBox(height: 24),
                                    LoginValidatedField(
                                      controller: _passwordController,
                                      hintText: context.tr('New password'),
                                      prefixIcon: Image.asset(AppAssets.passwordcheckimage),
                                      obscureText: _obscurePassword,
                                      validator: RegistrationValidators.password,
                                      suffix: IconButton(
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color.fromRGBO(83, 200, 193, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 17),
                                    LoginValidatedField(
                                      controller: _confirmController,
                                      hintText: context.tr('Confirm new password'),
                                      prefixIcon: Image.asset(AppAssets.passwordcheckimage),
                                      obscureText: _obscureConfirm,
                                      validator: _confirmValidator,
                                      suffix: IconButton(
                                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color.fromRGBO(83, 200, 193, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    PrimaryButton(
                                      label: context.tr('UPDATE PASSWORD'),
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
                                    child: Text(context.tr('Back to login')),
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
