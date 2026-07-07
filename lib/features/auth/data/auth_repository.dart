import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth/current_user_storage.dart';
import '../../../core/l10n/app_language_controller.dart';
import '../../../core/auth/auth_token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../domain/parent_registration_draft.dart';
import '../domain/teacher_registration_draft.dart';
import 'models/auth_session.dart';

/// Maps login dropdown label to API `type`: student | teacher | parent.
String loginTypeFromRoleLabel(String roleLabel) {
  switch (roleLabel.trim().toLowerCase()) {
    case 'student':
      return 'student';
    case 'teacher':
      return 'teacher';
    case 'parent':
      return 'parent';
    default:
      return 'student';
  }
}

/// Maps pace screen index to API `reading_level`.
String readingLevelFromPaceIndex(int selected) {
  switch (selected) {
    case 1:
      return 'intermediate';
    case 2:
      return 'advanced';
    case 0:
    default:
      return 'beginner';
  }
}

class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<void> _persistSession(AuthSession session, Map<String, dynamic> decoded) async {
    await AuthTokenStorage.instance.saveSession(
      accessToken: session.accessToken,
      tokenType: session.tokenType,
    );
    await CurrentUserStorage.instance.saveFromAuthEnvelope(decoded);
    final user = decoded['user'];
    if (user is Map<String, dynamic>) {
      final id = user['id'];
      final locale = user['locale'] as String?;
      if (id is int && id > 0) {
        await AppLanguageController.instance.bindUser(
          userId: id,
          serverLocale: locale,
        );
      }
    }
    await PushNotificationService.instance.syncTokenIfLoggedIn();
  }

  /// `POST /api/v1/auth/login` — persists [AuthSession] via [AuthTokenStorage].
  ///
  /// [type] must be `student`, `teacher`, or `parent` (matches selected role on login).
  Future<AuthSession> login({
    required String email,
    required String password,
    required String type,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'type': type.trim().toLowerCase(),
    };

    final http.Response res = await _client.postJson('/auth/login', body);

    if (res.statusCode == 200) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException(res.statusCode, 'Invalid response from server.');
        }
        final session = AuthSession.fromJson(decoded);
        await _persistSession(session, decoded);
        return session;
      } on ApiException {
        rethrow;
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    final parsed = parseApiError(res.body, fallback: 'Sign in failed. Please try again.');
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/forgot-password`
  Future<void> requestPasswordReset({required String email}) async {
    final res = await _client.postJson('/auth/forgot-password', {
      'email': email.trim().toLowerCase(),
    });
    if (res.statusCode == 200) return;
    final parsed = parseApiError(
      res.body,
      fallback: 'Could not send reset email. Please try again.',
    );
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/reset-password`
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _client.postJson('/auth/reset-password', {
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
    if (res.statusCode == 200) return;
    final parsed = parseApiError(
      res.body,
      fallback: 'Could not reset password. Please try again.',
    );
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/verify-email`
  Future<void> verifyEmail({required String token}) async {
    final res = await _client.postJson('/auth/verify-email', {'token': token});
    if (res.statusCode == 200) return;
    final parsed = parseApiError(
      res.body,
      fallback: 'Could not verify email. Please try again.',
    );
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/resend-verification`
  Future<void> resendVerificationEmail({required String email}) async {
    final res = await _client.postJson('/auth/resend-verification', {
      'email': email.trim().toLowerCase(),
    });
    if (res.statusCode == 200) return;
    final parsed = parseApiError(
      res.body,
      fallback: 'Could not resend verification email.',
    );
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/resend-verification/me`
  Future<void> resendVerificationForCurrentUser() async {
    final res = await _client.postJson('/auth/resend-verification/me', {}, authorized: true);
    if (res.statusCode == 200) return;
    final parsed = parseApiError(
      res.body,
      fallback: 'Could not resend verification email.',
    );
    throw ApiException(res.statusCode, parsed.message, code: parsed.code);
  }

  /// `POST /api/v1/auth/register` — student flow with [readingLevel] beginner | intermediate | advanced.
  /// Persists session when token is returned (same as teacher/parent registration).
  Future<AuthSession> registerStudent({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    required String readingLevel,
  }) async {
    final body = <String, dynamic>{
      'first_name': firstName,
      'email': email.trim().toLowerCase(),
      'password': password,
      'role_name': 'student',
      'reading_level': readingLevel,
    };
    final ln = lastName?.trim();
    if (ln != null && ln.isNotEmpty) {
      body['last_name'] = ln;
    }

    final http.Response res = await _client.postJson('/auth/register', body);

    if (res.statusCode == 201) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException(res.statusCode, 'Invalid response from server.');
        }
        final session = AuthSession.fromJson(decoded);
        await _persistSession(session, decoded);
        return session;
      } on ApiException {
        rethrow;
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Registration failed. Please try again.'),
    );
  }

  /// `POST /api/v1/auth/register` — teacher flow; persists session when token is returned.
  Future<AuthSession> registerTeacher(TeacherRegistrationDraft draft) async {
    final names = draft.splitName();
    final specs = draft.apiSpecializations();
    final custom = draft.specializationCustom?.trim();

    final teacher = <String, dynamic>{
      'school_name': draft.schoolName.trim(),
      'country': draft.country.trim(),
      'city': draft.city.trim(),
      'teaching_grade': draft.teachingGrade,
      'professional_role': draft.professionalRole,
      'specializations': specs,
      'specialization_custom': (custom != null && custom.isNotEmpty) ? custom : null,
      'years_experience': draft.yearsExperience,
      'verification_document_url': null,
    };
    final className = draft.className?.trim();
    if (className != null && className.isNotEmpty) {
      teacher['class_name'] = className;
    }

    final body = <String, dynamic>{
      'first_name': names.firstName,
      'email': draft.email.trim().toLowerCase(),
      'password': draft.password,
      'role_name': 'teacher',
      'phone': draft.phone.trim(),
      'teacher': teacher,
    };
    final ln = names.lastName?.trim();
    if (ln != null && ln.isNotEmpty) {
      body['last_name'] = ln;
    }

    final http.Response res = await _client.postJson('/auth/register', body);

    if (res.statusCode == 201) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException(res.statusCode, 'Invalid response from server.');
        }
        final session = AuthSession.fromJson(decoded);
        await _persistSession(session, decoded);
        return session;
      } on ApiException {
        rethrow;
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Registration failed. Please try again.'),
    );
  }

  /// `POST /api/v1/auth/register` — parent flow; persists session when token is returned.
  Future<AuthSession> registerParent(ParentRegistrationDraft draft) async {
    final names = draft.splitName();
    final questCode = draft.linkedStudentQuestCode?.trim();
    final childName = draft.pendingChildDisplayName?.trim();
    final childLevel = draft.pendingChildReadingLevel?.trim();

    final parent = <String, dynamic>{
      'subscription_plan_code': draft.subscriptionPlanCode,
      'linked_student_quest_code': (questCode != null && questCode.isNotEmpty) ? questCode : null,
      'pending_child_display_name': (childName != null && childName.isNotEmpty) ? childName : null,
      'pending_child_reading_level': (childLevel != null && childLevel.isNotEmpty) ? childLevel : null,
    };

    final body = <String, dynamic>{
      'first_name': names.firstName,
      'email': draft.email.trim().toLowerCase(),
      'password': draft.password,
      'role_name': 'parent',
      'phone': draft.phone.trim(),
      'parent': parent,
    };
    final ln = names.lastName?.trim();
    if (ln != null && ln.isNotEmpty) {
      body['last_name'] = ln;
    }

    final http.Response res = await _client.postJson('/auth/register', body);

    if (res.statusCode == 201) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException(res.statusCode, 'Invalid response from server.');
        }
        final session = AuthSession.fromJson(decoded);
        await _persistSession(session, decoded);
        return session;
      } on ApiException {
        rethrow;
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Registration failed. Please try again.'),
    );
  }

  /// `PATCH /api/v1/auth/password` — requires Bearer token.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _client.patchJson(
      '/auth/password',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      authorized: true,
    );

    if (res.statusCode == 200) {
      return;
    }

    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not update password. Please try again.'),
    );
  }
}
