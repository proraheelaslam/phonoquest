// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/phono_back_button.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/auth_repository.dart';
import '../../domain/teacher_registration_draft.dart';
import '../../../../core/l10n/app_language_controller.dart';

class professionalProfileScreen extends StatefulWidget {
  const professionalProfileScreen({super.key, this.draft});

  final TeacherRegistrationDraft? draft;

  @override
  State<professionalProfileScreen> createState() => _professionalProfileScreenState();
}

class _professionalProfileScreenState extends State<professionalProfileScreen> {
  final _customSpecController = TextEditingController();
  final _yearsController = TextEditingController();
  bool _submitting = false;

  final List<String> _specializations = const [
    'Dyslexia Support',
    'Early Literacy',
    'ESL/ ELL',
    'Special Education',
    'Intervention',
    'Custom',
  ];

  final Set<String> _selectedSpecializations = {'Early Literacy'};
  String _professionalRoleLabel = 'Lead Teacher';

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete the previous steps first.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _customSpecController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  String? _specializationError() {
    final hasChip = _selectedSpecializations.any((s) => s != 'Custom');
    final customText = _customSpecController.text.trim();
    final hasCustom = _selectedSpecializations.contains('Custom') && customText.isNotEmpty;
    if (!hasChip && !hasCustom) {
      return 'Select at least one specialization or enter a custom one.';
    }
    return null;
  }

  Future<void> _submit() async {
    final baseDraft = widget.draft;
    if (baseDraft == null || _submitting) return;

    final specError = _specializationError();
    if (specError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(specError), backgroundColor: Colors.red.shade800),
      );
      return;
    }

    final yearsText = _yearsController.text.trim();
    int? years;
    if (yearsText.isNotEmpty) {
      years = int.tryParse(yearsText);
      if (years == null || years < 0 || years > 80) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please enter a valid number of years (0–80).'))),
        );
        return;
      }
    }

    final roleApi = TeacherRegistrationDraft.professionalRoleOptions[_professionalRoleLabel] ?? 'lead_teacher';
    final custom = _selectedSpecializations.contains('Custom') ? _customSpecController.text.trim() : null;

    final draft = baseDraft.copyWith(
      professionalRole: roleApi,
      specializations: _selectedSpecializations.toList(),
      specializationCustom: (custom != null && custom.isNotEmpty) ? custom : null,
      yearsExperience: years,
    );

    setState(() => _submitting = true);
    try {
      await AuthRepository().registerTeacher(draft);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.setupcomplete);
    } on ApiException catch (e) {
      if (!mounted) return;
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

  Widget _professionalRoleField() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.softGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Image.asset(AppAssets.briefcaseimage, width: 17, height: 17, fit: BoxFit.contain),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _professionalRoleLabel,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black.withOpacity(.42)),
                items: TeacherRegistrationDraft.professionalRoleOptions.keys
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _professionalRoleLabel = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainTextField({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.softGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(.32), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _specializationChip(String label) {
    final bool isSelected = _selectedSpecializations.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSpecializations.remove(label);
          } else {
            _selectedSpecializations.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.softGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(.78),
          ),
        ),
      ),
    );
  }

  Widget _verificationUploadCard() {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: Colors.black.withOpacity(.12),
        radius: 12,
        dashWidth: 6,
        dashGap: 5,
        strokeWidth: 1.2,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDE7FF),
              ),
              alignment: Alignment.center,
              child: Image.asset(AppAssets.imagebackgroundimage, width: 24, height: 24, fit: BoxFit.contain ),
            ),
            SizedBox(height: 10),
            Text(context.tr('Upload Teaching License or Certificate'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(.78),
                  ),
            ),
            SizedBox(height: 6),
            Text(context.tr('PDF, JPG, or PNG (Max 30MB)'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11.5,
                    color: Colors.black.withOpacity(.42),
                  ),
            ),
          ],
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
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 245, 230, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(context.tr('STEP 4 OF 4'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Color.fromRGBO(248, 118, 146, 1),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(context.tr("Your Professional Profile"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                            ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(context.tr("Help us tailor PhonoQuest to your specific expertise."),
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
                              _professionalRoleField(),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(context.tr('Areas of Specialization'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.ink,
                                      ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(context.tr('Select all that apply'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 12.5,
                                        color: Colors.black.withOpacity(.52),
                                      ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _specializations.map(_specializationChip).toList(),
                                ),
                              ),
                              SizedBox(height: 12),
                              if (_selectedSpecializations.contains('Custom')) ...[
                                _plainTextField(hint: 'Type your Specialization', controller: _customSpecController),
                                SizedBox(height: 12),
                              ],
                              _plainTextField(
                                hint: 'Years of Experience',
                                controller: _yearsController,
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.ink,
                                            ),
                                        children: [
                                          TextSpan(text: context.tr('Verification Document ')),
                                          TextSpan(
                                            text: '(Optional)',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _verificationUploadCard(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      PrimaryButton(
                        label: _submitting ? 'SUBMITTING...' : 'NEXT',
                        onTap: _submitting ? () {} : _submit,
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
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.radius != radius;
  }
}
