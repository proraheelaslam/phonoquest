import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/link_child_account_screen.dart';
import 'core/l10n/app_language_controller.dart';
import 'core/l10n/app_locale.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/teacher_route_observer.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await PushNotificationService.instance.initialize();
  } catch (e, st) {
    debugPrint('PushNotificationService init skipped: $e\n$st');
  }
  runApp(const PhonoQuestApp());
}

class PhonoQuestApp extends StatefulWidget {
  const PhonoQuestApp({super.key});

  @override
  State<PhonoQuestApp> createState() => _PhonoQuestAppState();
}

class _PhonoQuestAppState extends State<PhonoQuestApp> {
  final _language = AppLanguageController.instance;

  @override
  void initState() {
    super.initState();
    _language.ensureInitialized();
    _language.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = _language.flutterLocale;
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      navigatorObservers: [teacherRouteObserver],
      debugShowCheckedModeBanner: false,
      title: 'PhonoQuest',
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocale.supportedCodes.map(AppLocale.toFlutterLocale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRouter.splash,
      routes: {
        AppRouter.parentLinkChildAccount: (_) => const LinkChildAccountScreen(),
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
