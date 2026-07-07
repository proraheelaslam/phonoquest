// ignore_for_file: prefer_const_constructors, camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/navigation/teacher_route_observer.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/data/teacher_workspace_controller.dart';
import '../../features/auth/presentation/Teachersscreens/teacher_classes.dart';
import '../../features/auth/presentation/Teachersscreens/teacher_reports.dart';
import '../../features/auth/presentation/Teachersscreens/teachers_dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'teacher_bottom_nav_bar.dart';

/// Keeps teacher tab screens alive and syncs shared data without duplicate API calls.
class TeacherMainShell extends StatefulWidget {
  const TeacherMainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static int indexForRoute(String? route) {
    switch (route) {
      case AppRouter.teachersdashboard:
        return 0;
      case AppRouter.teachersclasses:
        return 1;
      case AppRouter.teachersreports:
        return 2;
      case AppRouter.teacherssettings:
        return 3;
      default:
        return 0;
    }
  }

  @override
  State<TeacherMainShell> createState() => _TeacherMainShellState();
}

class _TeacherMainShellState extends State<TeacherMainShell>
    with WidgetsBindingObserver, RouteAware {
  late int _index;
  final Set<int> _visited = {};
  final _workspace = TeacherWorkspaceController.instance;
  Timer? _refreshTimer;
  bool _routeSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _index = widget.initialIndex.clamp(0, 3);
    _visited.add(_index);
    _workspace.syncTab(_index);
    _startAutoRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route is PageRoute) {
      teacherRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (_routeSubscribed) {
      teacherRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _workspace.invalidateAll();
    _workspace.syncVisitedTabs(_visited);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _workspace.syncVisitedTabs(_visited);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(TeacherWorkspaceController.autoRefreshInterval, (_) {
      if (!mounted) return;
      _workspace.syncVisitedTabs(_visited);
    });
  }

  void _onTabSelected(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _visited.add(index);
    });
    _workspace.syncTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _visited.contains(0)
              ? const teachersDashboardScreen(embeddedInShell: true)
              : const SizedBox.shrink(),
          _visited.contains(1)
              ? const teacherClassesScreen(embeddedInShell: true)
              : const SizedBox.shrink(),
          _visited.contains(2)
              ? const teacherReportsScreen(embeddedInShell: true)
              : const SizedBox.shrink(),
          _visited.contains(3)
              ? const SettingsScreen(
                  shell: SettingsShell.teacher,
                  embeddedInShell: true,
                )
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: teacherDashboardBottomNavBar(
        currentIndex: _index,
        onTap: _onTabSelected,
      ),
    );
  }
}
