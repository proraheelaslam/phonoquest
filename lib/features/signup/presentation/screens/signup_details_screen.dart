import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/input_field.dart';
import '../../../../shared/widgets/phono_back_button.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/student_registration_draft.dart';
import '../registration_validators.dart';
import '../../../../core/l10n/app_language_controller.dart';

class SignupDetailsScreen extends StatefulWidget {
  const SignupDetailsScreen({super.key});

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
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
      AppRouter.signupPace,
      arguments: StudentRegistrationDraft(
        fullName: _nameController.text.trim(),
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
                  padding: const EdgeInsets.fromLTRB(18, 50, 18, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(context.tr("Let's get you started."),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(context.tr("Enter your details to create your learning sanctuary. We'll keep your progress safe as you master new sounds."),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InputField(
                                  hint: "What's your name?",
                                  icon: Icons.person_outline,
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  validator: RegistrationValidators.fullName,
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
                                  suffix: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.black.withOpacity(.42),
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                                  suffix: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                    icon: Icon(
                                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.black.withOpacity(.42),
                                    ),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(context.tr('Must be at least 8 characters with one number.'),
                                    style: TextStyle(fontSize: 10.5, color: Colors.black.withOpacity(.42)),
                                  ),
                                ),
                                SizedBox(height: 36),
                                PrimaryButton(label: context.tr('NEXT'), onTap: _goNext),
                                SizedBox(height: 28),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(.72)),
                                    children: [
                                      TextSpan(text: context.tr('By signing up, you agree to our ')),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(color: Color(0xFFF47495), fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 8),
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
