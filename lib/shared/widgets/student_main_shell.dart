// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../core/notifications/push_notification_service.dart';
import '../../core/router/app_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/journey/journey.dart';
import '../../features/progress/presentation/screens/student_progress.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'dashboard_bottom_nav_bar.dart';

/// Keeps student tab screens alive — avoids refetching APIs on every bottom-nav tap.
class StudentMainShell extends StatefulWidget {
  const StudentMainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static int indexForRoute(String? route) {
    switch (route) {
      case AppRouter.dashboard:
        return 0;
      case AppRouter.journey:
        return 1;
      case AppRouter.progress:
        return 2;
      case AppRouter.settings:
        return 3;
      default:
        return 0;
    }
  }

  @override
  State<StudentMainShell> createState() => _StudentMainShellState();
}

class _StudentMainShellState extends State<StudentMainShell> with WidgetsBindingObserver {
  late int _index;
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _index = widget.initialIndex.clamp(0, 3);
    _visited.add(_index);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PushNotificationService.instance.syncTokenIfLoggedIn();
    }
  }

  void _onTabSelected(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _visited.contains(0)
              ? DashboardScreen(embeddedInShell: true, isActive: _index == 0)
              : const SizedBox.shrink(),
          _visited.contains(1)
              ? JourneyScreen(embeddedInShell: true, isActive: _index == 1)
              : const SizedBox.shrink(),
          _visited.contains(2)
              ? const studentProgressScreen(embeddedInShell: true)
              : const SizedBox.shrink(),
          _visited.contains(3)
              ? const SettingsScreen(embeddedInShell: true)
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: DashboardBottomNavBar(
        currentIndex: _index,
        onTap: _onTabSelected,
      ),
    );
  }
}
