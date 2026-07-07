// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/l10n/app_locale.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/network/api_client.dart';
import 'settings_navigation_helper.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/parent_dashboard_repository.dart';
import '../../data/models/learner_profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../profile_photo_picker.dart';
import '../../../../shared/widgets/profile_avatar.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _gradeController = TextEditingController();
  final _readingLevelController = TextEditingController();

  String _selectedLocale = AppLocale.en;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  String _linkVerifyMessage = '';
  bool _isVerifyingLink = false;
  bool _uploadingAvatar = false;
  LearnerProfile? _profile;
  late ProfileRepository _profileRepository;
  final _parentRepo = ParentDashboardRepository();

  bool get _isTeacher =>
      (_profile?.roleName ?? '').toLowerCase() == 'teacher';

  bool get _isStudent =>
      (_profile?.roleName ?? '').toLowerCase() == 'student';

  bool get _isParent =>
      (_profile?.roleName ?? '').toLowerCase() == 'parent';

  String? _settingsReturnRoute;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadProfile();
  }

  void _initializeRepository() {
    final apiClient = ApiClient();
    _profileRepository = ProfileRepository(apiClient: apiClient);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.startsWith('/')) {
      _settingsReturnRoute = args;
    }
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final payload = await _profileRepository.fetchMyProfile(
        forceRefresh: forceRefresh,
      );

      if (payload.status) {
        setState(() {
          _profile = payload.data;
          _nameController.text = payload.data.primaryName.isNotEmpty
              ? payload.data.primaryName
              : payload.data.displayName;
          _emailController.text = payload.data.email;
          _gradeController.text = payload.data.gradeLevel ?? '';
          _readingLevelController.text = payload.data.readingLevel;
          _selectedLocale = AppLocale.normalize(payload.data.locale);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = payload.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_uploadingAvatar) return;
    setState(() => _uploadingAvatar = true);
    try {
      final uploaded = await pickAndUploadProfilePhoto(
        context: context,
        repository: _profileRepository,
      );
      if (uploaded == null || !mounted) return;

      final uploadedAvatar = uploaded.avatar?.trim() ?? '';
      setState(() => _profile = uploaded);

      await _loadProfile(forceRefresh: true);
      if (!mounted) return;

      if (uploadedAvatar.isNotEmpty) {
        final currentAvatar = _profile?.avatar?.trim() ?? '';
        if (currentAvatar.isEmpty) {
          setState(() {
            _profile = _profile?.copyWith(avatar: uploadedAvatar) ?? uploaded;
          });
        }
      }
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _verifyChildLink() async {
    final code = _gradeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _linkVerifyMessage = 'Enter a Quest ID first (email, PQ code, or student name).';
      });
      return;
    }

    setState(() {
      _isVerifyingLink = true;
      _linkVerifyMessage = '';
    });

    try {
      final result = await _parentRepo.verifyChildLink(code);
      if (!mounted) return;
      setState(() {
        _isVerifyingLink = false;
        if (result.found) {
          final name = result.childName ?? 'Student';
          final pq = result.questCode != null ? ' (${result.questCode})' : '';
          _linkVerifyMessage = 'Found: $name$pq. Tap Save Changes to link.';
        } else {
          _linkVerifyMessage = result.hint ?? 'No student found. Check the Quest ID and try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifyingLink = false;
        _linkVerifyMessage = 'Could not verify: $e';
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() {
        _isSaving = true;
        _errorMessage = '';
      });

      final updateData = ProfileUpdateRequest(
        displayName: _nameController.text.isNotEmpty ? _nameController.text : null,
        gradeLevel: _gradeController.text.isNotEmpty ? _gradeController.text : null,
        readingLevel: _readingLevelController.text.isNotEmpty ? _readingLevelController.text : null,
        locale: _selectedLocale,
      );

      final payload = await _profileRepository.updateProfile(updateData);

      if (payload.status) {
        await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
        setState(() {
          _profile = payload.data;
          _isSaving = false;
        });

        if (mounted) {
          var message = context.t.profileUpdated;
          if (_isParent && _gradeController.text.trim().isNotEmpty) {
            try {
              final verify = await _parentRepo.verifyChildLink(_gradeController.text.trim());
              if (verify.found) {
                message =
                    'Linked to ${verify.childName ?? 'your child'}. Status and dashboard will show live progress.';
              } else {
                message =
                    'Saved, but no student matched that Quest ID yet. Tap Verify Link to check.';
              }
            } catch (_) {}
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = payload.message;
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: $e';
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _gradeController.dispose();
    _readingLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(context.tr('Loading profile...'), style: textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage', style: textTheme.bodyMedium, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: Text(context.tr('Retry')),
              ),
            ],
          ),
        ),
      );
    }

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
                            onTap: () async => navigateBackToSettings(
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
                                AppAssets.backimage, // 👈 apni image ka path
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Account Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromRGBO(26, 28, 28, 1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 5),

                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            ProfileAvatar(
                              avatarUrl: _profile?.avatar,
                              fallbackAsset: ProfileAvatar.fallbackForRole(_profile?.roleName),
                              size: 110,
                              showEditBadge: true,
                              useBuiltinEditIcon: true,
                              onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                            ),
                            if (_uploadingAvatar)
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(247, 205, 135, 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _isParent
                                ? 'PARENT'
                                : '${_profile?.roleName.toUpperCase()}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(26, 28, 28, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isStudent) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: Color.fromRGBO(176, 120, 0, 1)),
                              SizedBox(width: 6),
                              Text(
                                'Learning Progress',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color.fromRGBO(26, 28, 28, 1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _progressStat(
                                  value: '12',
                                  label: 'MODULES\nDONE',
                                  valueColor: const Color.fromRGBO(36, 88, 181, 1),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _progressStat(
                                  value: '450',
                                  label: 'STARS\nEARNED',
                                  valueColor: const Color.fromRGBO(22, 163, 74, 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ] else
                    SizedBox(height: 12),

                  _inputField(
                    controller: _nameController,
                    hintText: "What's your name?",
                    prefixIcon: Icons.person_outline_rounded,
                    readOnly: false,
                  ),

                  SizedBox(height: 10),

                  _inputField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.mail_outline_rounded,
                    readOnly: true,
                  ),

                  SizedBox(height: 10),

                  if (_isParent) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(230, 242, 255, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Link your child',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            context.tr("Enter the student's login email, PQ code (e.g. PQ42), or the name on their PhonoQuest profile. This connects Home and Status to their real progress."),
                            style: GoogleFonts.lexend(fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],

                  _inputField(
                    controller: _gradeController,
                    hintText: _isTeacher
                        ? 'Teaching Grade'
                        : _isParent
                            ? 'Child Quest ID (email or PQ code)'
                            : 'Grade Level',
                    prefixIcon: Icons.school_outlined,
                    readOnly: false,
                  ),

                  if (_isParent) ...[
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _isVerifyingLink ? null : _verifyChildLink,
                        icon: _isVerifyingLink
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified_user_outlined, size: 18),
                        label: Text(
                          _isVerifyingLink ? 'Checking…' : 'Verify Link',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (_linkVerifyMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _linkVerifyMessage,
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            color: _linkVerifyMessage.startsWith('Found')
                                ? const Color(0xFF10B981)
                                : const Color(0xFFB45309),
                            height: 1.35,
                          ),
                        ),
                      ),
                  ],

                  if (!_isTeacher) ...[
                    SizedBox(height: 10),
                    _inputField(
                      controller: _readingLevelController,
                      hintText: _isParent ? "Child's Reading Level" : 'Reading Level',
                      prefixIcon: Icons.book_outlined,
                      readOnly: false,
                    ),
                  ],

                  SizedBox(height: 10),

                  _languageField(),

                  SizedBox(height: 10),

                  _joinDateField(),

                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _isSaving
                        ? PrimaryButton(label: context.tr('SAVING...'),
                            onTap: () {},
                          )
                        : PrimaryButton(label: context.tr('SAVE'),
                            onTap: _saveProfile,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressStat({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(243, 243, 243, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(100, 116, 139, 1),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool readOnly,
    String? trailingText,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color.fromRGBO(26, 28, 28, 1),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color.fromRGBO(156, 163, 175, 1),
        ),
        prefixIcon: Icon(prefixIcon, color: const Color.fromRGBO(124, 132, 145, 1), size: 18),
        suffix: trailingText != null
            ? Text(
                trailingText,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(148, 163, 184, 1),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(83, 200, 193, 1), width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _languageField() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(AppLocale.displayNameLocalized(AppLocale.en, context.t.localeCode)),
                    onTap: () => Navigator.pop(ctx, AppLocale.en),
                  ),
                  ListTile(
                    title: Text(AppLocale.displayNameLocalized(AppLocale.es, context.t.localeCode)),
                    onTap: () => Navigator.pop(ctx, AppLocale.es),
                  ),
                ],
              ),
            );
          },
        );
        if (selected != null && mounted) {
          setState(() => _selectedLocale = AppLocale.normalize(selected));
        }
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(243, 243, 243, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
              Image.asset(
                AppAssets.translateimage, // 👈 apni image ka path
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),            SizedBox(width: 10),
            Text(
              context.t.accountLanguageLabel,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(26, 28, 28, 1),
              ),
            ),
            const Spacer(),
            Text(
              AppLocale.displayNameLocalized(_selectedLocale, context.t.localeCode),
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(26, 28, 28, 1),
              ),
            ),
            SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color.fromRGBO(124, 132, 145, 1)),
          ],
        ),
      ),
    );
  }

  Widget _joinDateField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(243, 243, 243, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Image.asset(
                AppAssets.calenderimage, // 👈 apni image ka path
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
          SizedBox(width: 10),
          Text(
            'Join Date',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(26, 28, 28, 1),
            ),
          ),
          const Spacer(),
          Text(
            '25 October 2023',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color.fromRGBO(148, 163, 184, 1),
            ),
          ),
        ],
      ),
    );
  }
}


