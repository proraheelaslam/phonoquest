// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_query.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/auth_repository.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.email, this.initialToken});

  final String? email;
  final String? initialToken;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authRepo = AuthRepository();
  bool _submitting = false;
  bool _verified = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    final token = widget.initialToken ?? RouteQuery.parameter('token');
    if (token != null && token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifyToken(token));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_email == null && args is String && args.contains('@')) {
      _email = args;
    }
  }

  Future<void> _verifyToken(String token) async {
    setState(() => _submitting = true);
    try {
      await _authRepo.verifyEmail(token: token);
      if (!mounted) return;
      setState(() {
        _verified = true;
        _submitting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Something went wrong. Please try again.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _submitting = true);
    try {
      final token = await AuthTokenStorage.instance.readAccessToken();
      if (token != null) {
        await _authRepo.resendVerificationForCurrentUser();
      } else {
        final email = _email?.trim();
        if (email == null || email.isEmpty) {
          throw ApiException(400, 'Enter your email on the login screen first.');
        }
        await _authRepo.resendVerificationEmail(email: email);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Verification email sent.'))),
      );
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  _verified
                                      ? context.tr('Email verified!')
                                      : context.tr('Verify your email'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _verified
                                      ? context.tr(
                                          'Email verified successfully. You can sign in now.',
                                        )
                                      : context.tr(
                                          'We sent a verification link to your email. Open the link, or tap resend below.',
                                        ),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexend(fontSize: 13, height: 1.5),
                                ),
                                if (_email != null && !_verified) ...[
                                  SizedBox(height: 10),
                                  Text(
                                    _email!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(83, 200, 193, 1),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 24),
                                if (_submitting)
                                  const CircularProgressIndicator()
                                else if (_verified)
                                  PrimaryButton(
                                    label: context.tr('Log In'),
                                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRouter.login,
                                      (route) => false,
                                    ),
                                  )
                                else ...[
                                  PrimaryButton(
                                    label: context.tr('Resend verification email'),
                                    onTap: _resend,
                                  ),
                                  SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacementNamed(
                                      context,
                                      AppRouter.login,
                                    ),
                                    child: Text(context.tr('Back to login')),
                                  ),
                                ],
                              ],
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
