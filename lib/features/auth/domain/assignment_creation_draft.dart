/// Wizard state passed across assign-module → recipients → review → detail.
class AssignmentCreationDraft {
  final String moduleCode;
  final String moduleTitle;
  final String? moduleDescription;
  final String levelLabel;
  final String recipientMode;
  final int? classId;
  final String? className;
  final List<int> selectedStudentIds;
  final int? recipientStudentCount;
  final DateTime? scheduleDueAt;
  final String? teacherNote;
  final int? assignmentId;

  const AssignmentCreationDraft({
    required this.moduleCode,
    required this.moduleTitle,
    this.moduleDescription,
    required this.levelLabel,
    this.recipientMode = 'entire_class',
    this.classId,
    this.className,
    this.selectedStudentIds = const [],
    this.recipientStudentCount,
    this.scheduleDueAt,
    this.teacherNote,
    this.assignmentId,
  });

  int get recipientCount {
    if (recipientMode == 'individual_students') {
      return selectedStudentIds.length;
    }
    return 0;
  }

  AssignmentCreationDraft copyWith({
    String? moduleCode,
    String? moduleTitle,
    String? moduleDescription,
    String? levelLabel,
    String? recipientMode,
    int? classId,
    String? className,
    List<int>? selectedStudentIds,
    int? recipientStudentCount,
    DateTime? scheduleDueAt,
    String? teacherNote,
    int? assignmentId,
    bool clearClassId = false,
    bool clearScheduleDueAt = false,
  }) {
    return AssignmentCreationDraft(
      moduleCode: moduleCode ?? this.moduleCode,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      moduleDescription: moduleDescription ?? this.moduleDescription,
      levelLabel: levelLabel ?? this.levelLabel,
      recipientMode: recipientMode ?? this.recipientMode,
      classId: clearClassId ? null : (classId ?? this.classId),
      className: className ?? this.className,
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
      recipientStudentCount: recipientStudentCount ?? this.recipientStudentCount,
      scheduleDueAt: clearScheduleDueAt ? null : (scheduleDueAt ?? this.scheduleDueAt),
      teacherNote: teacherNote ?? this.teacherNote,
      assignmentId: assignmentId ?? this.assignmentId,
    );
  }
}
