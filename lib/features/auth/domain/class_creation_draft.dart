/// Data collected across create class → mascot → add students.
class ClassCreationDraft {
  final String name;
  final String gradeLevel;
  final String mascotCode;
  final int? classId;

  const ClassCreationDraft({
    required this.name,
    required this.gradeLevel,
    required this.mascotCode,
    this.classId,
  });

  ClassCreationDraft copyWith({int? classId, String? mascotCode}) {
    return ClassCreationDraft(
      name: name,
      gradeLevel: gradeLevel,
      mascotCode: mascotCode ?? this.mascotCode,
      classId: classId ?? this.classId,
    );
  }

  static const mascotCodes = [
    'alphabet_lounge',
    'blend_forest',
    'vowel_learning',
    'phonics_cards',
    'smart_chart',
    'practice',
  ];

  static String mascotCodeAtIndex(int index) {
    if (index < 0 || index >= mascotCodes.length) return mascotCodes.first;
    return mascotCodes[index];
  }

  static String gradeLevelFromUi(String label) {
    switch (label) {
      case 'Pre-K':
        return 'pre_k';
      case 'Grade 1':
        return 'kindergarten';
      case 'Grade 2':
        return 'first_grade';
      case 'Grade 3+':
        return 'second_plus';
      default:
        return 'kindergarten';
    }
  }
}
