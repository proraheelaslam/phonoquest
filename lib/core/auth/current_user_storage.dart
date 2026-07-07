import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalUserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String roleName;
  final String displayName;
  final String readingLevel;
  final String? gradeLevel;

  const LocalUserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleName,
    required this.displayName,
    required this.readingLevel,
    required this.gradeLevel,
  });

  factory LocalUserProfile.fromMap(Map<String, dynamic> map) {
    final first = (map['first_name'] as String?)?.trim() ?? '';
    final last = (map['last_name'] as String?)?.trim() ?? '';
    final display = (map['display_name'] as String?)?.trim();
    final mergedName = [first, last].where((s) => s.isNotEmpty).join(' ').trim();
    return LocalUserProfile(
      firstName: first,
      lastName: last,
      email: (map['email'] as String?)?.trim() ?? '',
      roleName: (map['role_name'] as String?)?.trim() ?? '',
      displayName: (display != null && display.isNotEmpty) ? display : mergedName,
      readingLevel: (map['reading_level'] as String?)?.trim() ?? '',
      gradeLevel: (map['grade_level'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toMap() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role_name': roleName,
        'display_name': displayName,
        'reading_level': readingLevel,
        'grade_level': gradeLevel,
      };
}

class CurrentUserStorage {
  CurrentUserStorage._();

  static final CurrentUserStorage instance = CurrentUserStorage._();

  static const _keyCurrentUser = 'phonoquest_current_user';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveUserMap(Map<String, dynamic> user) async {
    final p = await _prefs;
    await p.setString(_keyCurrentUser, jsonEncode(user));
  }

  Future<void> saveFromAuthEnvelope(Map<String, dynamic> authPayload) async {
    final user = authPayload['user'];
    if (user is Map<String, dynamic>) {
      await saveUserMap(user);
    }
  }

  Future<LocalUserProfile?> readProfile() async {
    final p = await _prefs;
    final raw = p.getString(_keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return LocalUserProfile.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final p = await _prefs;
    await p.remove(_keyCurrentUser);
  }
}
