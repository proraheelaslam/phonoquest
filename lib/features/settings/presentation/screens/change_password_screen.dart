// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../signup/presentation/registration_validators.dart';
import 'settings_navigation_helper.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/l10n/app_language_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _settingsReturnRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.startsWith('/')) {
      _settingsReturnRoute = args;
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _authRepo.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Password updated successfully.'),
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color.fromRGBO(16, 185, 129, 1),
        ),
      );

      await navigateBackToSettings(context, returnRoute: _settingsReturnRoute);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade800,
        ),
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
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
              padding: const EdgeInsets.fromLTRB(20, 7, 20, 26),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 52,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _submitting
                                  ? null
                                  : () => navigateBackToSettings(
                                        context,
                                        returnRoute: _settingsReturnRoute,
                                      ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  AppAssets.backimage,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          ),
                          Text(context.tr('Change Password'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color.fromRGBO(26, 28, 28, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Image.asset(
                        AppAssets.changepasswordimage,
                        width: 110,
                        height: 110,
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(context.tr('Change Password'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(26, 28, 28, 1),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(context.tr('Create a new password to keep your\naccount safe and secure.'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        height: 1.25,
                        color: const Color.fromRGBO(21, 21, 21, 1),
                      ),
                    ),
                    SizedBox(height: 22),
                    _passwordField(
                      controller: _currentPasswordController,
                      hintText: context.tr('Current password'),
                      obscureText: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) => RegistrationValidators.changePasswordField(
                        v,
                        emptyMessage: 'Please enter your current password.',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12),
                    _passwordField(
                      controller: _newPasswordController,
                      hintText: context.tr('New password'),
                      obscureText: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: (v) => RegistrationValidators.changePasswordNew(
                        v,
                        _currentPasswordController.text,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12),
                    _passwordField(
                      controller: _confirmPasswordController,
                      hintText: context.tr('Confirm new password'),
                      obscureText: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => RegistrationValidators.confirmPassword(
                        v,
                        _newPasswordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _updatePassword(),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: PrimaryButton(
                        label: context.tr('UPDATE PASSWORD'),
                        isBusy: _submitting,
                        onTap: _updatePassword,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: !_submitting,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color.fromRGBO(26, 28, 28, 1),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color.fromRGBO(156, 163, 175, 1),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: SizedBox(
            width: 12,
            height: 12,
            child: Image.asset(
              AppAssets.passwordcheckimage,
              fit: BoxFit.contain,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 44),
        suffixIcon: IconButton(
          onPressed: onToggle,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color.fromRGBO(83, 200, 193, 1),
          ),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(83, 200, 193, 1), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1),
        ),
      ),
    );
  }
}
