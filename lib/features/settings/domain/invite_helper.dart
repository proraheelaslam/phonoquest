import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/router/app_router.dart';

/// Builds invite codes and share links for the Invite Friend screen.
abstract final class InviteHelper {
  /// Matches backend `student_quest_code(user_id)` → `PQ{user_id}`.
  static String codeForUserId(int userId) {
    if (userId <= 0) return '';
    return 'PQ$userId';
  }

  /// Sign-up deep link including the invite code (hash routing on web).
  static String signupLink(String inviteCode) {
    final code = inviteCode.trim();
    if (code.isEmpty) return '';

    if (kIsWeb) {
      final base = Uri.base;
      final path = base.path.endsWith('/') ? base.path : '${base.path}/';
      return '${base.origin}$path#${AppRouter.signupRole}?invite=$code';
    }

    return 'https://phonoquest.app${AppRouter.signupRole}?invite=$code';
  }

  static String shareMessage({
    required String inviterName,
    required String inviteCode,
    required String inviteLink,
    required bool isSpanish,
  }) {
    final name = inviterName.trim().isEmpty
        ? (isSpanish ? 'Un amigo' : 'A friend')
        : inviterName.trim();

    if (isSpanish) {
      return '$name te invita a PhonoQuest. '
          'Usa el código $inviteCode o regístrate aquí: $inviteLink';
    }
    return '$name invited you to PhonoQuest! '
        'Use invite code $inviteCode or sign up here: $inviteLink';
  }
}
