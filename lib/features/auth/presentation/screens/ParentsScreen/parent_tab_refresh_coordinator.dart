import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_request_coordinator.dart';

/// Throttles parent tab refreshes and busts GET cache when a tab becomes active.
class ParentTabRefreshCoordinator {
  ParentTabRefreshCoordinator._();

  static const Duration minRefreshInterval = Duration(seconds: 25);

  static final Map<int, DateTime> _lastRefreshByTab = {};

  static bool shouldRefreshTab(int tabIndex, {bool force = false}) {
    if (force) return true;
    final last = _lastRefreshByTab[tabIndex];
    if (last == null) return true;
    return DateTime.now().difference(last) >= minRefreshInterval;
  }

  static void markTabRefreshed(int tabIndex) {
    _lastRefreshByTab[tabIndex] = DateTime.now();
  }

  static void invalidateParentDashboardCache() {
    ApiRequestCoordinator.invalidate(pathContains: '/dashboard/parent');
  }

  static void invalidateAllParentCaches() {
    invalidateParentDashboardCache();
    ApiRequestCoordinator.invalidate(pathContains: '/messages/parent');
  }

  /// Call before a forced reload (pull-to-refresh, child linked, tab revisit).
  static void prepareForcedReload() {
    invalidateParentDashboardCache();
    ApiClient.clearRequestCache();
  }
}

/// Implemented by parent bottom-nav tabs embedded in [ParentMainShell].
abstract class ParentShellTab {
  Future<void> reloadFromShell({bool force = false});
}

enum ParentShellTabIndex {
  home,
  status,
  resources,
  settings;
}
