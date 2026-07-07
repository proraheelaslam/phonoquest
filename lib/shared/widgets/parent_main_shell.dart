// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../features/auth/presentation/screens/ParentsScreen/parent_tab_refresh_coordinator.dart';
import '../../features/auth/presentation/screens/ParentsScreen/parents_dashboard_screen.dart';
import '../../features/auth/presentation/screens/ParentsScreen/parents_reports.dart';
import '../../features/auth/presentation/screens/ParentsScreen/parents_status.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'parent_bottom_nav_bar.dart';

/// Keeps parent tab screens alive and refreshes data when a tab is re-selected.
class ParentMainShell extends StatefulWidget {
  const ParentMainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static int indexForRoute(String? route) {
    switch (route) {
      case AppRouter.parentsdashboardscreen:
        return 0;
      case AppRouter.parentsstatusscreen:
        return 1;
      case AppRouter.parentsreportsscreen:
        return 2;
      case AppRouter.parentssettingscreen:
        return 3;
      default:
        return 0;
    }
  }

  @override
  State<ParentMainShell> createState() => _ParentMainShellState();
}

class _ParentMainShellState extends State<ParentMainShell> {
  late int _index;
  final Set<int> _visited = {};

  final _homeKey = GlobalKey<State<parentsDashboardScreen>>();
  final _statusKey = GlobalKey<State<parentsStatusScreen>>();
  final _resourcesKey = GlobalKey<State<parentsReportsScreen>>();

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
    _visited.add(_index);
    ParentTabRefreshCoordinator.markTabRefreshed(_index);
  }

  void _onTabSelected(int index) {
    if (index == _index) {
      _refreshTab(index, force: true);
      return;
    }
    final firstVisit = !_visited.contains(index);
    setState(() {
      _index = index;
      _visited.add(index);
    });
    if (firstVisit) {
      ParentTabRefreshCoordinator.markTabRefreshed(index);
    } else {
      _refreshTab(index);
    }
  }

  Future<void> _refreshTab(int index, {bool force = false}) async {
    if (index == ParentShellTabIndex.settings.index) return;
    if (!force && !ParentTabRefreshCoordinator.shouldRefreshTab(index)) {
      return;
    }

    ParentTabRefreshCoordinator.invalidateParentDashboardCache();

    final tab = _tabForIndex(index);
    if (tab != null) {
      await tab.reloadFromShell(force: force);
      ParentTabRefreshCoordinator.markTabRefreshed(index);
    }
  }

  ParentShellTab? _tabForIndex(int index) {
    final Object? state = switch (index) {
      0 => _homeKey.currentState,
      1 => _statusKey.currentState,
      2 => _resourcesKey.currentState,
      _ => null,
    };
    return state is ParentShellTab ? state : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _visited.contains(0)
              ? parentsDashboardScreen(
                  key: _homeKey,
                  embeddedInShell: true,
                )
              : const SizedBox.shrink(),
          _visited.contains(1)
              ? parentsStatusScreen(
                  key: _statusKey,
                  embeddedInShell: true,
                )
              : const SizedBox.shrink(),
          _visited.contains(2)
              ? parentsReportsScreen(
                  key: _resourcesKey,
                  embeddedInShell: true,
                )
              : const SizedBox.shrink(),
          _visited.contains(3)
              ? const SettingsScreen(
                  shell: SettingsShell.parent,
                  embeddedInShell: true,
                )
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: parentDashboardBottomNavBar(
        currentIndex: _index,
        onTap: _onTabSelected,
      ),
    );
  }
}
