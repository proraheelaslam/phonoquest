// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import 'package:phonoquest_signup_flow/shared/widgets/teacher_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/auth_navigation.dart';
import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/auth/session_logout.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/primary_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/settings_menu_section.dart';
import '../../data/models/learner_profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../subscription/data/subscription_models.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../profile_photo_picker.dart';
import 'settings_navigation_helper.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/settings_profile_photo.dart';

/// Which app shell owns this settings page (controls bottom nav only).
enum SettingsShell { student, teacher, parent }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.shell = SettingsShell.student,
    this.embeddedInShell = false,
  });

  final SettingsShell shell;
  final bool embeddedInShell;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ProfileRepository _profileRepository;
  LearnerProfile? _profile;
  LocalUserProfile? _localProfile;
  bool _isLoading = true;
  bool _uploadingAvatar = false;
  String _errorMessage = '';
  SubscriptionMe? _subscription;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(apiClient: ApiClient());
    AppLanguageController.instance.addListener(_onLanguageChanged);
    _loadLocalProfile();
    _loadProfile();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    if (_isTeacherShell || _isParentShell) return;
    try {
      final me = await SubscriptionRepository().fetchMe();
      if (!mounted) return;
      setState(() => _subscription = me);
    } catch (_) {}
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  bool get _isTeacherShell => widget.shell == SettingsShell.teacher;

  bool get _isParentShell => widget.shell == SettingsShell.parent;

  String get _settingsReturnRoute => settingsRouteForShellName(widget.shell.name);

  Future<void> _redirectNonStudentAway() async {
    if (_isTeacherShell || _isParentShell) return;
    final role = _profile?.roleName ?? _localProfile?.roleName ?? '';
    final target = settingsRouteForRole(role);
    if (!mounted || target == AppRouter.settings) return;
    Navigator.pushReplacementNamed(context, target);
  }

  Future<void> _loadLocalProfile() async {
    final local = await CurrentUserStorage.instance.readProfile();
    if (!mounted || local == null) return;
    setState(() {
      _localProfile = local;
    });
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    try {
      final payload = await _profileRepository.fetchMyProfile(
        forceRefresh: forceRefresh,
      );
      if (payload.status && payload.data.email.isNotEmpty) {
        await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
        setState(() {
          _profile = payload.data;
          _errorMessage = '';
        });
        if (widget.shell == SettingsShell.student) await _redirectNonStudentAway();
      } else {
        setState(() {
          _errorMessage =
              payload.message.isNotEmpty ? payload.message : 'No profile found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
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
      await _loadLocalProfile();
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    await logoutSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
  }

  String get _profileName {
    final primary = _profile?.primaryName;
    if (primary != null && primary.isNotEmpty) return primary;
    final name = _profile?.displayName;
    if (name != null && name.isNotEmpty) return name;
    final local = _localProfile;
    if (local != null && local.displayName.isNotEmpty) return local.displayName;
    if (_isLoading) return 'Loading...';
    return 'No name';
  }

  String get _profileEmail {
    final email = _profile?.email;
    if (email != null && email.isNotEmpty) return email;
    final local = _localProfile;
    if (local != null && local.email.isNotEmpty) return local.email;
    if (_isLoading) return 'Loading...';
    return 'No email';
  }

  String get _profileRole {
    if (_isParentShell) {
      final role = _profile?.roleName ?? _localProfile?.roleName ?? '';
      if (role.toLowerCase() == 'parent') return 'PARENTS';
      if (role.isNotEmpty) return role.toUpperCase();
      return 'PARENTS';
    }
    final role = _profile?.roleName;
    if (role != null && role.isNotEmpty) return role.toUpperCase();
    final local = _localProfile;
    if (local != null && local.roleName.isNotEmpty) return local.roleName.toUpperCase();
    return 'STUDENT';
  }

  String get _profileLevel {
    if (_isParentShell) {
      final subtitle = _profile?.parentSubtitle;
      if (subtitle != null && subtitle.isNotEmpty) return subtitle;
      final plan = _profile?.subscriptionPlanCode;
      if (plan != null && plan.isNotEmpty) {
        return 'Plan: ${plan.replaceAll('_', ' ')}';
      }
      if (_isLoading) return 'Loading...';
      return 'Family plan';
    }
    final teacherSubtitle = _profile?.teacherSubtitle;
    if (teacherSubtitle != null && teacherSubtitle.isNotEmpty) {
      return teacherSubtitle;
    }
    if (_profile?.gradeLevel != null && _profile!.gradeLevel!.isNotEmpty) {
      return 'Grade ${_profile!.gradeLevel}';
    }
    if (_profile?.readingLevel != null && _profile!.readingLevel.isNotEmpty) {
      return _profile!.readingLevel;
    }
    final local = _localProfile;
    if (local?.gradeLevel != null && local!.gradeLevel!.isNotEmpty) {
      return 'Grade ${local.gradeLevel}';
    }
    if (local != null && local.readingLevel.isNotEmpty) return local.readingLevel;
    if (_isLoading) return 'Loading...';
    return 'Level 0';
  }

  Widget _buildBottomNav() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (_isTeacherShell) {
      return teacherDashboardBottomNavBar(
        currentIndex: teacherDashboardBottomNavBar.indexFromRoute(routeName),
        onTap: (index) {
          final targetRoute = teacherDashboardBottomNavBar.routeFromIndex(index);
          final currentRoute = routeName;
          if (targetRoute != currentRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      );
    }
    if (_isParentShell) {
      return parentDashboardBottomNavBar(
        currentIndex: parentDashboardBottomNavBar.indexFromRoute(routeName),
        onTap: (index) {
          final targetRoute = parentDashboardBottomNavBar.routeFromIndex(index);
          final currentRoute = routeName;
          if (targetRoute != currentRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      );
    }
    return DashboardBottomNavBar(
      currentIndex: DashboardBottomNavBar.indexFromRoute(routeName),
      onTap: (index) {
        final targetRoute = DashboardBottomNavBar.routeFromIndex(index);
        final currentRoute = routeName;
        if (targetRoute != currentRoute) {
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = context.t;
    final languageLabel = _profile?.languageLabel.isNotEmpty == true
        ? _profile!.languageLabel
        : AppLanguageController.instance.displayLabel;
    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      bottomNavigationBar: widget.embeddedInShell ? null : _buildBottomNav(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50, // 👈 header height (adjust if needed)
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      // ✅ Center Title
                      Text(
                        t.settingsTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      // ✅ Right Side Widgets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(247, 205, 135, 1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.starimage,
                                  width: 12,
                                  height: 12,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '20',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRouter.notifications),
                            icon: const Icon(Icons.notifications_none_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Profile Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(83, 200, 193, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SettingsProfilePhoto(
                        avatarUrl: _profile?.avatar,
                        isUploading: _uploadingAvatar,
                        onEditTap: _pickAndUploadAvatar,
                        fallbackAsset: ProfileAvatar.fallbackForRole(
                          _profile?.roleName,
                          parentShell: widget.shell == SettingsShell.parent,
                        ),
                      ),
                      SizedBox(width: 14),

                      // Name, Email, Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _profileName,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(26, 28, 28, 1),
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(255, 191, 0, 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _profileRole,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(21, 21, 21, 1),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 2),

                            Text(
                              _profileEmail,
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color.fromRGBO(65, 71, 84, 1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppAssets.levelstarimage,
                                    width: 14,
                                    height: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    _profileLevel,
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromRGBO(26, 28, 28, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage.isNotEmpty && !_isLoading) ...[
                  SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 18),

                SettingsMenuSection(
                  title: t.accountSection,
                  // ignore: prefer_const_literals_to_create_immutables
                  items: [
                  SettingsMenuItem(
                        iconImage: AppAssets.accountimage, // 👈 image path
                        title: t.accountDetails,
                        subtitle: t.accountDetailsSubtitle,
                        onTap: () async {
                          final updated = await Navigator.pushNamed(
                            context,
                            AppRouter.accountdetails,
                            arguments: _settingsReturnRoute,
                          );
                          if (!mounted) return;
                          if (updated == true) {
                            await _loadLocalProfile();
                            await _loadProfile(forceRefresh: true);
                          }
                        },
                      ),
                    SettingsMenuItem(
                      iconImage: AppAssets.passwordimage, // 👈 image path
                      title: t.changePassword,
                      subtitle: t.changePasswordSubtitle,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.password,
                        arguments: _settingsReturnRoute,
                      ),
                    ),
                    SettingsMenuItem(
                      iconImage: AppAssets.notificationsimage, // 👈 image path
                      title: t.tr('Notifications'),
                      onTap: () => Navigator.pushNamed(context, AppRouter.notifications),
                    ),
                    if (!_isTeacherShell && !_isParentShell)
                      SettingsMenuItem(
                        iconData: Icons.speed_rounded,
                        title: t.tr('Choose your pace'),
                        subtitle: t.tr('Beginner, Intermediate, or Advanced'),
                        onTap: () async {
                          final updated = await Navigator.pushNamed(context, AppRouter.studentPace);
                          if (!mounted) return;
                          if (updated == true) {
                            await _loadLocalProfile();
                            await _loadProfile();
                          }
                        },
                      ),
                    if (_isParentShell || _isTeacherShell || (!_isTeacherShell && !_isParentShell))
                      SettingsMenuItem(
                        iconData: Icons.workspace_premium_outlined,
                        title: t.subscription,
                        subtitle: _isParentShell
                            ? t.subscriptionFamilySubtitle
                            : _isTeacherShell
                                ? context.tr('View complimentary educator access')
                                : (_subscription?.planManagedBy == 'parent' || _subscription?.inClass == true)
                                    ? t.subscriptionViewSubtitle
                                    : context.tr('Manage your subscription and payment'),
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRouter.subscription);
                          if (!mounted) return;
                          await _loadProfile();
                          await _loadSubscription();
                        },
                      ),
                  ],
                ),

                SizedBox(height: 16),

                SettingsMenuSection(
                  title: t.appSettingsSection,
                  // ignore: prefer_const_literals_to_create_immutables
                  items: [
                    SettingsMenuItem(
                      iconImage: AppAssets.languageimage, // 👈 image path
                      title: t.languageMenuTitle,
                      subtitle: t.languageMenuSubtitle,
                      trailingText: '($languageLabel)',
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRouter.language,
                          arguments: _settingsReturnRoute,
                        );
                        if (!mounted) return;
                        await _loadProfile();
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16),

                SettingsMenuSection(
                  title: t.supportSection,
                  // ignore: prefer_const_literals_to_create_immutables
                  items: [
                    SettingsMenuItem(
                       iconImage: AppAssets.inviteimage, // 👈 image path
                      title: t.inviteFriend,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.inviteFriend,
                        arguments: _settingsReturnRoute,
                      ),
                    ),
                    SettingsMenuItem(
                       iconImage: AppAssets.helpimage, // 👈 image path
                      title: t.helpSupport,
                      subtitle: t.helpSupportSubtitle,
                      onTap: () => Navigator.pushNamed(context, AppRouter.helpSupport),
                    ),
                    SettingsMenuItem(
                      iconImage: AppAssets.policyimage,
                      title: context.tr('Terms & policies'),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.termsPolicies,
                        arguments: _settingsReturnRoute,
                      ),
                    ),
                    SettingsMenuItem(
                       iconImage: AppAssets.versionimage, // 👈 image path
                      title: context.tr('App Version'),
                      onTap: () => Navigator.pushNamed(context, AppRouter.appVersion),
                    ),
                    SettingsMenuItem(
                      iconData: Icons.logout,
                      title: 'Logout',
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}


