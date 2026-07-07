import 'package:flutter/material.dart';

import '../../features/auth/data/models/auth_session.dart';
import 'app_router.dart';
import 'auth_navigation.dart';

/// After login/register, go straight to the role dashboard.
void navigateAfterAuth(BuildContext context, AuthSession session) {
  Navigator.pushReplacementNamed(
    context,
    dashboardRouteForRole(session.roleName),
  );
}

void navigateToVerifyEmail(BuildContext context, {String? email}) {
  Navigator.pushNamed(
    context,
    AppRouter.verifyEmail,
    arguments: email,
  );
}
