import '../../features/dashboard/data/student_module_routes.dart';
import '../navigation/app_navigator.dart';
import '../router/app_router.dart';

/// Navigate from FCM data payload after the user taps a notification.
void navigateFromNotificationPayload(Map<String, dynamic> data) {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;

  final kind = (data['kind'] as String?)?.trim().toLowerCase();
  final route = (data['route'] as String?)?.trim();

  switch (kind) {
    case 'assignment':
      if (route != null && route.isNotEmpty) {
        navigator.pushNamed(studentModuleRoute(route));
      }
      return;
    case 'assignment_cancelled':
      navigator.pushNamed(
        route != null && route.isNotEmpty ? route : AppRouter.notifications,
      );
      return;
    case 'teacher_message':
    case 'child_assignment':
    case 'child_linked':
    case 'assignment_completed':
      if (route == AppRouter.notifications || route == null || route.isEmpty) {
        navigator.pushNamed(AppRouter.notifications);
        return;
      }
      navigator.pushNamed(route);
      return;
    case 'parent_linked':
      navigator.pushNamed(
        route != null && route.isNotEmpty ? route : AppRouter.teachersclasses,
      );
      return;
    case 'students_added':
      navigator.pushNamed(
        route != null && route.isNotEmpty ? route : AppRouter.teachersclasses,
      );
      return;
    case 'student_struggling':
      navigator.pushNamed(
        route != null && route.isNotEmpty
            ? route
            : AppRouter.teachersStrugglingStudents,
      );
      return;
    case 'class_milestone':
      navigator.pushNamed(
        route != null && route.isNotEmpty
            ? route
            : AppRouter.teacherCelebrationReport,
      );
      return;
    case 'test':
      navigator.pushNamed(
        route != null && route.isNotEmpty ? route : AppRouter.notifications,
      );
      return;
    default:
      break;
  }

  if (route != null && route.isNotEmpty) {
    navigator.pushNamed(route);
  }
}
