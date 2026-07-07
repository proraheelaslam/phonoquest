/// Carries student signup fields from the details step to the pace step.
class StudentRegistrationDraft {
  final String fullName;
  final String email;
  final String password;

  const StudentRegistrationDraft({
    required this.fullName,
    required this.email,
    required this.password,
  });

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
}
