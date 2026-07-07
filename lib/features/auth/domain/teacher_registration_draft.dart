/// Carries teacher signup fields across personal info → class setup → professional profile.
class TeacherRegistrationDraft {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String schoolName;
  final String country;
  final String city;
  final String teachingGrade;
  final String? className;
  final String professionalRole;
  final List<String> specializations;
  final String? specializationCustom;
  final int? yearsExperience;

  const TeacherRegistrationDraft({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.schoolName = '',
    this.country = '',
    this.city = '',
    this.teachingGrade = 'kindergarten',
    this.className,
    this.professionalRole = 'lead_teacher',
    this.specializations = const [],
    this.specializationCustom,
    this.yearsExperience,
  });

  TeacherRegistrationDraft copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? schoolName,
    String? country,
    String? city,
    String? teachingGrade,
    String? className,
    String? professionalRole,
    List<String>? specializations,
    String? specializationCustom,
    int? yearsExperience,
  }) {
    return TeacherRegistrationDraft(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      schoolName: schoolName ?? this.schoolName,
      country: country ?? this.country,
      city: city ?? this.city,
      teachingGrade: teachingGrade ?? this.teachingGrade,
      className: className ?? this.className,
      professionalRole: professionalRole ?? this.professionalRole,
      specializations: specializations ?? this.specializations,
      specializationCustom: specializationCustom ?? this.specializationCustom,
      yearsExperience: yearsExperience ?? this.yearsExperience,
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

  /// Maps UI grade labels to API `teaching_grade` values.
  static String teachingGradeFromUi(String label) {
    switch (label) {
      case 'Pre-K':
        return 'pre_k';
      case 'Kindergarten':
        return 'kindergarten';
      case '1st Grade':
        return 'first_grade';
      case '2nd Grade +':
        return 'second_plus';
      default:
        return 'kindergarten';
    }
  }

  static String teachingGradeToUi(String apiValue) {
    switch (apiValue) {
      case 'pre_k':
        return 'Pre-K';
      case 'kindergarten':
        return 'Kindergarten';
      case 'first_grade':
        return '1st Grade';
      case 'second_plus':
        return '2nd Grade +';
      default:
        return 'Kindergarten';
    }
  }

  static const professionalRoleOptions = <String, String>{
    'Lead Teacher': 'lead_teacher',
    'Assistant Teacher': 'assistant_teacher',
    'Reading Specialist': 'reading_specialist',
    'Speech Pathologist': 'speech_pathologist',
  };

  static String professionalRoleLabel(String apiValue) {
    for (final entry in professionalRoleOptions.entries) {
      if (entry.value == apiValue) return entry.key;
    }
    return 'Lead Teacher';
  }

  List<String> apiSpecializations() {
    return specializations.where((s) => s != 'Custom').toList();
  }
}
