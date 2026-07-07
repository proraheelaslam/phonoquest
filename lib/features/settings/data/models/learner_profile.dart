class LearnerProfilePayload {
  final LearnerProfile data;
  final bool status;
  final String code;
  final String message;

  LearnerProfilePayload({
    required this.data,
    required this.status,
    required this.code,
    required this.message,
  });

  factory LearnerProfilePayload.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
        : null;
    final data = dataMap != null
        ? LearnerProfile.fromJson(dataMap)
        : const LearnerProfile();

    return LearnerProfilePayload(
      status: LearnerProfilePayload.isSuccessful(json, data),
      code: (json['code'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      data: data,
    );
  }

  /// True when API reports success or [data] contains a loaded user profile.
  static bool isSuccessful(Map<String, dynamic> json, LearnerProfile data) {
    if (_readBool(json['status'])) return true;
    final code = json['code']?.toString() ?? '';
    if (code == 'PROFILE_FETCHED' ||
        code == 'PROFILE_UPDATED' ||
        code == 'AVATAR_UPDATED') {
      return true;
    }
    if (data.email.isNotEmpty && data.roleName.isNotEmpty) return true;
    return false;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1';
    }
    if (value is num) return value != 0;
    return false;
  }

  /// Build envelope from `GET /auth/me` user object.
  factory LearnerProfilePayload.fromAuthMe(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['user'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final data = LearnerProfile.fromAuthUser(user);
    return LearnerProfilePayload(
      status: data.email.isNotEmpty,
      code: 'PROFILE_FETCHED',
      message: 'Profile loaded successfully',
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LearnerProfile {
  final int id;
  final int userId;
  final String displayName;
  final String? gradeLevel;
  final String readingLevel;
  final bool dyslexiaSupportEnabled;
  final int roleId;
  final String roleName;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String status;
  final bool emailVerified;
  final String? teacherProfile;
  final String? parentProfile;
  final String fullName;
  final String? schoolName;
  final String? teachingGrade;
  final String? className;
  final String? city;
  final String? country;
  final String? subscriptionPlanCode;
  final String? pendingChildDisplayName;
  final String? avatar;
  final String locale;
  final String languageLabel;

  const LearnerProfile({
    this.id = 0,
    this.userId = 0,
    this.displayName = '',
    this.gradeLevel,
    this.readingLevel = '',
    this.dyslexiaSupportEnabled = false,
    this.roleId = 0,
    this.roleName = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone,
    this.status = '',
    this.emailVerified = true,
    this.teacherProfile,
    this.parentProfile,
    this.fullName = '',
    this.schoolName,
    this.teachingGrade,
    this.className,
    this.city,
    this.country,
    this.subscriptionPlanCode,
    this.pendingChildDisplayName,
    this.avatar,
    this.locale = 'en',
    this.languageLabel = 'English',
  });

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    final merged = Map<String, dynamic>.from(json);
    _mergeNestedProfile(merged, json['teacher_profile']);
    _mergeNestedProfile(merged, json['parent_profile']);

    return LearnerProfile(
      id: merged['id'] is int ? merged['id'] as int : int.tryParse('${merged['id']}') ?? 0,
      userId: merged['user_id'] is int
          ? merged['user_id'] as int
          : int.tryParse('${merged['user_id']}') ?? 0,
      displayName: (merged['display_name'] as String?) ?? '',
      gradeLevel: merged['grade_level'] as String?,
      readingLevel: (merged['reading_level'] as String?) ?? '',
      dyslexiaSupportEnabled: merged['dyslexia_support_enabled'] as bool? ?? false,
      roleId: merged['role_id'] is int
          ? merged['role_id'] as int
          : int.tryParse('${merged['role_id']}') ?? 0,
      roleName: (merged['role_name'] as String?) ?? '',
      firstName: (merged['first_name'] as String?) ?? '',
      lastName: (merged['last_name'] as String?) ?? '',
      email: (merged['email'] as String?) ?? '',
      phone: merged['phone'] as String?,
      status: merged['status'] is String ? merged['status'] as String : '',
      emailVerified: merged['email_verified'] as bool? ?? true,
      teacherProfile: merged['teacher_profile']?.toString(),
      parentProfile: merged['parent_profile']?.toString(),
      fullName: (merged['full_name'] as String?) ?? '',
      schoolName: merged['school_name'] as String?,
      teachingGrade: merged['teaching_grade'] as String?,
      className: merged['class_name'] as String?,
      city: merged['city'] as String?,
      country: merged['country'] as String?,
      subscriptionPlanCode: merged['subscription_plan_code'] as String?,
      pendingChildDisplayName: merged['pending_child_display_name'] as String?,
      avatar: merged['avatar'] as String?,
      locale: (merged['locale'] as String?) ?? 'en',
      languageLabel: (merged['language_label'] as String?) ?? 'English',
    );
  }

  static void _mergeNestedProfile(
    Map<String, dynamic> target,
    dynamic nested,
  ) {
    if (nested is! Map<String, dynamic>) return;
    for (final entry in nested.entries) {
      target.putIfAbsent(entry.key, () => entry.value);
    }
  }

  /// Maps `GET /auth/me` → same shape as `/profiles/me` [data].
  factory LearnerProfile.fromAuthUser(Map<String, dynamic> user) {
    final merged = Map<String, dynamic>.from(user);
    _mergeNestedProfile(merged, user['teacher_profile']);
    _mergeNestedProfile(merged, user['parent_profile']);
    if (!merged.containsKey('display_name') || (merged['display_name'] as String?)?.isEmpty == true) {
      final first = (merged['first_name'] as String?) ?? '';
      final last = (merged['last_name'] as String?) ?? '';
      merged['display_name'] = '$first $last'.trim();
    }
    if (!merged.containsKey('full_name') || (merged['full_name'] as String?)?.isEmpty == true) {
      merged['full_name'] = merged['display_name'];
    }
    return LearnerProfile.fromJson(merged);
  }

  String get primaryName {
    if (fullName.isNotEmpty) return fullName;
    if (displayName.isNotEmpty) return displayName;
    final parts = [firstName, lastName].where((s) => s.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return '';
  }

  String get roleBadge =>
      roleName.isNotEmpty ? roleName.toUpperCase() : 'USER';

  String? get teacherSubtitle {
    if (schoolName != null && schoolName!.isNotEmpty) {
      final location = [city, country].where((s) => s != null && s.isNotEmpty).join(', ');
      return location.isNotEmpty ? '$schoolName · $location' : schoolName;
    }
    if (teachingGrade != null && teachingGrade!.isNotEmpty) {
      return 'Grade: $teachingGrade';
    }
    if (className != null && className!.isNotEmpty) return className;
    return null;
  }

  String? get parentSubtitle {
    if (pendingChildDisplayName != null && pendingChildDisplayName!.isNotEmpty) {
      return 'Child: $pendingChildDisplayName';
    }
    if (subscriptionPlanCode != null && subscriptionPlanCode!.isNotEmpty) {
      return 'Plan: ${subscriptionPlanCode!.replaceAll('_', ' ')}';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'grade_level': gradeLevel,
      'reading_level': readingLevel,
      'dyslexia_support_enabled': dyslexiaSupportEnabled,
      'role_id': roleId,
      'role_name': roleName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'status': status,
      'teacher_profile': teacherProfile,
      'parent_profile': parentProfile,
      'full_name': fullName,
      'avatar': avatar,
      'locale': locale,
      'language_label': languageLabel,
    };
  }

  LearnerProfile copyWith({
    int? id,
    int? userId,
    String? displayName,
    String? gradeLevel,
    String? readingLevel,
    bool? dyslexiaSupportEnabled,
    int? roleId,
    String? roleName,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? status,
    String? teacherProfile,
    String? parentProfile,
    String? fullName,
    String? avatar,
    String? locale,
    String? languageLabel,
  }) {
    return LearnerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      readingLevel: readingLevel ?? this.readingLevel,
      dyslexiaSupportEnabled: dyslexiaSupportEnabled ?? this.dyslexiaSupportEnabled,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      parentProfile: parentProfile ?? this.parentProfile,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      locale: locale ?? this.locale,
      languageLabel: languageLabel ?? this.languageLabel,
    );
  }
}

class ProfileUpdateRequest {
  final String? displayName;
  final String? dateOfBirth;
  final String? gradeLevel;
  final String? readingLevel;
  final bool? dyslexiaSupportEnabled;
  final String? notes;
  final String? locale;

  const ProfileUpdateRequest({
    this.displayName,
    this.dateOfBirth,
    this.gradeLevel,
    this.readingLevel,
    this.dyslexiaSupportEnabled,
    this.notes,
    this.locale,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (displayName != null) map['display_name'] = displayName;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth;
    if (gradeLevel != null) map['grade_level'] = gradeLevel;
    if (readingLevel != null) map['reading_level'] = readingLevel;
    if (dyslexiaSupportEnabled != null) map['dyslexia_support_enabled'] = dyslexiaSupportEnabled;
    if (notes != null) map['notes'] = notes;
    if (locale != null) map['locale'] = locale;
    return map;
  }
}
