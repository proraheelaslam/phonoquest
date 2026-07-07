import 'app_router.dart';

/// Home route after login or cold start, based on API `user.role_name`.
String dashboardRouteForRole(String? roleName) {
  switch ((roleName ?? 'student').toLowerCase()) {
    case 'teacher':
      return AppRouter.teachersdashboard;
    case 'parent':
      return AppRouter.parentsdashboardscreen;
    case 'student':
    default:
      return AppRouter.dashboard;
  }
}

/// Settings route for the signed-in role (`/settings` is student-only).
String settingsRouteForRole(String? roleName) {
  switch ((roleName ?? 'student').toLowerCase()) {
    case 'teacher':
      return AppRouter.teacherssettings;
    case 'parent':
      return AppRouter.parentssettingscreen;
    case 'student':
    default:
      return AppRouter.settings;
  }
}

/// Settings route for app shell (`student` | `teacher` | `parent`).
String settingsRouteForShellName(String shellName) {
  switch (shellName) {
    case 'teacher':
      return AppRouter.teacherssettings;
    case 'parent':
      return AppRouter.parentssettingscreen;
    case 'student':
    default:
      return AppRouter.settings;
  }
}
