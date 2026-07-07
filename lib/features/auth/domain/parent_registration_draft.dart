/// Carries parent signup fields across personal info → connect child → plan selection.
class ParentRegistrationDraft {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String? linkedStudentQuestCode;
  final String? pendingChildDisplayName;
  final String? pendingChildReadingLevel;
  final String subscriptionPlanCode;

  const ParentRegistrationDraft({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.linkedStudentQuestCode,
    this.pendingChildDisplayName,
    this.pendingChildReadingLevel,
    this.subscriptionPlanCode = 'basic',
  });

  ParentRegistrationDraft copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? linkedStudentQuestCode,
    String? pendingChildDisplayName,
    String? pendingChildReadingLevel,
    String? subscriptionPlanCode,
    bool clearQuestCode = false,
    bool clearChildName = false,
    bool clearChildLevel = false,
  }) {
    return ParentRegistrationDraft(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      linkedStudentQuestCode: clearQuestCode
          ? null
          : (linkedStudentQuestCode ?? this.linkedStudentQuestCode),
      pendingChildDisplayName: clearChildName
          ? null
          : (pendingChildDisplayName ?? this.pendingChildDisplayName),
      pendingChildReadingLevel: clearChildLevel
          ? null
          : (pendingChildReadingLevel ?? this.pendingChildReadingLevel),
      subscriptionPlanCode: subscriptionPlanCode ?? this.subscriptionPlanCode,
    );
  }

  ({String firstName, String? lastName}) splitName() {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return (firstName: '', lastName: null);
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: null);
    }
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  static const planCodes = <String, String>{
    'basic': 'basic',
    'intermediate': 'intermediate',
    'advance': 'advance',
  };
}
