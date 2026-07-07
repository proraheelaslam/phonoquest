import '../l10n/app_language_controller.dart';
import '../network/api_client.dart';
import '../notifications/push_notification_service.dart';
import '../../features/auth/data/teacher_workspace_controller.dart';
import 'auth_token_storage.dart';
import 'current_user_storage.dart';

/// Clears local auth after push token cleanup (unregister needs a valid Bearer token).
Future<void> logoutSession() async {
  try {
    await PushNotificationService.instance.unregisterCurrentToken();
  } catch (_) {}

  await AuthTokenStorage.instance.clear();
  await CurrentUserStorage.instance.clear();
  await AppLanguageController.instance.unbindUser();
  TeacherWorkspaceController.instance.reset();
  ApiClient.clearRequestCache();
}
