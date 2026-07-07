import 'package:flutter/material.dart';

import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/router/auth_navigation.dart';

/// Returns to the settings screen the user came from, or the correct role-based settings route.
Future<void> navigateBackToSettings(
  BuildContext context, {
  String? returnRoute,
}) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return;
  }

  final fromArgs = ModalRoute.of(context)?.settings.arguments;
  final route = returnRoute ??
      (fromArgs is String && fromArgs.startsWith('/') ? fromArgs : null);

  if (route != null) {
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    return;
  }

  final local = await CurrentUserStorage.instance.readProfile();
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(
    context,
    settingsRouteForRole(local?.roleName),
    (r) => false,
  );
}
