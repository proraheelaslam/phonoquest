import 'package:flutter/material.dart';

import '../../../../../core/router/app_router.dart';

/// Opens the dedicated Link Child Account screen.
/// Returns `true` when the child was linked successfully.
Future<bool?> openParentLinkChildAccount(
  BuildContext context, {
  String? returnRoute,
}) {
  return AppRouter.pushLinkChildAccount(context);
}
