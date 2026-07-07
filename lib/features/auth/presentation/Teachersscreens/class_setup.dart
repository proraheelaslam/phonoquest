// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/phono_back_button.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/teacher_registration_draft.dart';
import '../../../../core/l10n/app_language_controller.dart';

class classSetupScreen extends StatefulWidget {
  const classSetupScreen({super.key, this.draft});

  final TeacherRegistrationDraft? draft;

  @override
  State<classSetupScreen> createState() => _classSetupScreenState();
}

class _classSetupScreenState extends State<classSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _classNameController = TextEditingController();

  final List<String> _gradeLevels = const [
    'Pre-K',
    'Kindergarten',
    '1st Grade',
    '2nd Grade +',
  ];

  String _selectedGrade = 'Kindergarten';

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete your personal info first.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    final draft = widget.draft;
    if (draft == null) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.professionalprofile,
      arguments: draft.copyWith(
        schoolName: _schoolController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        teachingGrade: TeacherRegistrationDraft.teachingGradeFromUi(_selectedGrade),
        className: _classNameController.text.trim().isEmpty ? null : _classNameController.text.trim(),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required String imagePath,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.black.withOpacity(.32),
        fontSize: 14,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          imagePath,
          width: 17,
          height: 17,
          fit: BoxFit.contain,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    );
  }

  Widget _textField({
    required String imagePath,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? helper,
    Color? backgroundColor,
  }) {
    final bg = backgroundColor ?? AppTheme.softGrey;

    if (validator == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              decoration: _fieldDecoration(hint: hint, imagePath: imagePath),
            ),
          ),
          if (helper != null) ...[
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                helper,
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.black.withOpacity(.42),
                ),
              ),
            ),
          ],
        ],
      );
    }

    return FormField<String>(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: controller.text,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: field.hasError
                    ? Border.all(color: Colors.red.shade700, width: 1)
                    : null,
              ),
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  field.didChange(value);
                  field.validate();
                },
                decoration: _fieldDecoration(hint: hint, imagePath: imagePath),
              ),
            ),
            if (field.hasError) ...[
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Text(
                  field.errorText ?? '',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.red.shade700,
                    height: 1.25,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
            if (helper != null && !field.hasError) ...[
              SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  helper,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.black.withOpacity(.42),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _gradeButton(String label) {
    final bool isSelected = _selectedGrade == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGrade = label),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.yellow : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withOpacity(.06)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Colors.black.withOpacity(.78),
            ),
          ),
        ),
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
            // Background SVG Image
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.signUpBackground,
                fit: BoxFit.cover,
              ),
            ),

            // Your UI
            SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
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
                            child: Text(context.tr('STEP 3 OF 4'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Color.fromRGBO(248, 118, 146, 1),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(context.tr("School & Class Setup"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                            ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(context.tr("Tell us where you're teaching so we can organize your student rosters."),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              _textField(
                                imagePath: AppAssets.schoolnameimage,
                                hint: 'School Name',
                                controller: _schoolController,
                                validator: (v) => _requiredField(v, 'Please enter your school name.'),
                              ),
                              SizedBox(height: 12),
                              _textField(
                                imagePath: AppAssets.countryimage,
                                hint: 'Country',
                                controller: _countryController,
                                validator: (v) => _requiredField(v, 'Please enter your country.'),
                              ),
                              SizedBox(height: 12),
                              _textField(
                                imagePath: AppAssets.cityimage,
                                hint: 'City',
                                controller: _cityController,
                                validator: (v) => _requiredField(v, 'Please enter your city.'),
                              ),
                              SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.softGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                     Image.asset( AppAssets.classinformationimage, width: 20, height: 20, fit: BoxFit.contain),
                                        SizedBox(width: 8),
                                        Text(context.tr('Class Information'),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.ink,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black.withOpacity(.78),
                                            ),
                                        children: [
                                          TextSpan(text: context.tr('Grade Level ')),
                                          TextSpan(text: '*', style: TextStyle(color: AppTheme.pink)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _gradeButton(_gradeLevels[0]),
                                        SizedBox(width: 10),
                                        _gradeButton(_gradeLevels[1]),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _gradeButton(_gradeLevels[2]),
                                        SizedBox(width: 10),
                                        _gradeButton(_gradeLevels[3]),
                                      ],
                                    ),
                                    SizedBox(height: 14),
                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black.withOpacity(.78),
                                            ),
                                        children: [
                                          TextSpan(text: context.tr('Class Name ')),
                                          TextSpan(
                                            text: '(Optional)',
                                            style: TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _textField(
                                      imagePath: AppAssets.morningowelsimage,
                                      hint: 'e.g. Morning Owls',
                                      controller: _classNameController,
                                      helper: 'Give your class a fun name to help students identify it.',
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      PrimaryButton(
                        label: context.tr('NEXT'),
                        onTap: _goNext,
                      ),
                      SizedBox(height: 16),
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
                      SizedBox(height: 10),
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
            ),
          ],
        ),
      ),
    );
  }
}
