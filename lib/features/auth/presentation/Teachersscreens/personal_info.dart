// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/input_field.dart';
import '../../../../shared/widgets/phono_back_button.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../signup/presentation/registration_validators.dart';
import '../../domain/teacher_registration_draft.dart';
import '../../../../core/l10n/app_language_controller.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pushNamed(
      context,
      AppRouter.classsetup,
      arguments: TeacherRegistrationDraft(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
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
              child: SvgPicture.asset(
                AppAssets.signUpBackground,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: PhonoShell(
                stepLabel: '',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 245, 230, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(context.tr('STEP 2 OF 4'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Color.fromRGBO(248, 118, 146, 1),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(context.tr('Personal Info.'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(context.tr("Let's get to know you! Enter your details to start setting up your teacher profile."),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(height: 40),
                        InputField(
                          hint: "What's your name?",
                          icon: Icons.person_outline,
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          validator: RegistrationValidators.fullName,
                        ),
                        SizedBox(height: 14),
                        InputField(
                          hint: 'Phone Number',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: RegistrationValidators.phone,
                        ),
                        SizedBox(height: 14),
                        InputField(
                          hint: 'Email address',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: RegistrationValidators.email,
                        ),
                        SizedBox(height: 14),
                        InputField(
                          hint: 'Create a password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                          validator: RegistrationValidators.password,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: Colors.black.withOpacity(.38),
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        InputField(
                          hint: 'Retype password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          controller: _confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _goNext(),
                          validator: (v) => RegistrationValidators.confirmPassword(v, _passwordController.text),
                          suffix: GestureDetector(
                            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                              _obscureConfirm ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: Colors.black.withOpacity(.38),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(context.tr('Must be at least 8 characters with one number.'),
                            style: TextStyle(fontSize: 10.5, color: Colors.black.withOpacity(.42)),
                          ),
                        ),
                        SizedBox(height: 50),
                        PrimaryButton(label: context.tr('NEXT'), onTap: _goNext),
                        SizedBox(height: 40),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(.72)),
                            children: [
                              TextSpan(text: context.tr('By signing up, you agree to our ')),
                              TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFFF47495), fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: PhonoBackButton(onTap: () => Navigator.pop(context)),
                        ),
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
}
