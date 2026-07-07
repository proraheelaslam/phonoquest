import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/auth/session_logout.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/auth_navigation.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../settings/data/repositories/profile_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AppLanguageController.instance.ensureInitialized();
    _timer = Timer(const Duration(milliseconds: 1800), _navigateFromSplash);
  }

  Future<void> _navigateFromSplash() async {
    if (!mounted) return;

    final token = await AuthTokenStorage.instance.readAccessToken();
    if (token != null) {
      try {
        final profile = await ProfileRepository(apiClient: ApiClient()).fetchMyProfile();
        await AppLanguageController.instance.syncFromProfile(
          userId: profile.data.userId,
          locale: profile.data.locale,
        );
        await PushNotificationService.instance.syncTokenIfLoggedIn();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, dashboardRouteForRole(profile.data.roleName));
        await PushNotificationService.instance.consumePendingNotificationNavigation();
        return;
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) {
          await logoutSession();
        } else {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, dashboardRouteForRole('student'));
          return;
        }
      } catch (_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, dashboardRouteForRole('student'));
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.signupRole);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.splashBg,
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              AppAssets.splashLogo,
              width: 260,
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
