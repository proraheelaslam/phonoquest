import 'dart:convert';

class ClassRecipientSummary {
  final int classId;
  final String className;
  final int recipientsCount;
  final String recipientLabel;

  const ClassRecipientSummary({
    required this.classId,
    required this.className,
    required this.recipientsCount,
    required this.recipientLabel,
  });

  factory ClassRecipientSummary.fromJson(Map<String, dynamic> json) {
    return ClassRecipientSummary(
      classId: _asInt(json['class_id']),
      className: (json['class_name'] as String?) ?? '',
      recipientsCount: _asInt(json['recipients_count']),
      recipientLabel: (json['recipient_label'] as String?) ?? '',
    );
  }
}

class ParentSearchItem {
  final int studentId;
  final String parentLabel;
  final String childName;
  final String summary;

  const ParentSearchItem({
    required this.studentId,
    required this.parentLabel,
    required this.childName,
    required this.summary,
  });

  factory ParentSearchItem.fromJson(Map<String, dynamic> json) {
    return ParentSearchItem(
      studentId: _asInt(json['student_id']),
      parentLabel: (json['parent_label'] as String?) ?? '',
      childName: (json['child_name'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
    );
  }
}

class IndividualMessageResult {
  final int studentId;
  final String studentName;
  final bool parentLinked;
  final bool deliveredNow;
  final bool queuedForParent;
  final String? studentQuestCode;
  final String? parentLinkHint;

  const IndividualMessageResult({
    required this.studentId,
    required this.studentName,
    required this.parentLinked,
    required this.deliveredNow,
    required this.queuedForParent,
    this.studentQuestCode,
    this.parentLinkHint,
  });

  factory IndividualMessageResult.fromJson(Map<String, dynamic> json) {
    return IndividualMessageResult(
      studentId: _asInt(json['student_id']),
      studentName: (json['student_name'] as String?) ?? '',
      parentLinked: json['parent_linked'] == true,
      deliveredNow: json['delivered_now'] == true,
      queuedForParent: json['queued_for_parent'] == true,
      studentQuestCode: json['student_quest_code'] as String?,
      parentLinkHint: json['parent_link_hint'] as String?,
    );
  }

  static IndividualMessageResult fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid message send payload.');
    }
    return IndividualMessageResult.fromJson(data);
  }
}

class RecentMessageItem {
  final int id;
  final String toLabel;
  final String messagePreview;
  final String messageType;
  final String messageTypeLabel;
  final String sentAtLabel;
  final int? recipientsCount;
  final bool isClassMessage;

  const RecentMessageItem({
    required this.id,
    required this.toLabel,
    required this.messagePreview,
    required this.messageType,
    required this.messageTypeLabel,
    required this.sentAtLabel,
    this.recipientsCount,
    required this.isClassMessage,
  });

  factory RecentMessageItem.fromJson(Map<String, dynamic> json) {
    return RecentMessageItem(
      id: _asInt(json['id']),
      toLabel: (json['to_label'] as String?) ?? '',
      messagePreview: (json['message_preview'] as String?) ?? '',
      messageType: (json['message_type'] as String?) ?? 'class_update',
      messageTypeLabel: (json['message_type_label'] as String?) ?? 'Class Update',
      sentAtLabel: (json['sent_at_label'] as String?) ?? '',
      recipientsCount: json['recipients_count'] == null
          ? null
          : _asInt(json['recipients_count']),
      isClassMessage: json['is_class_message'] == true,
    );
  }
}

String messageTypeApiFromUi(String label) {
  switch (label.trim().toLowerCase()) {
    case 'progress report':
      return 'progress_report';
    case 'reminder':
      return 'reminder';
    case 'milestone':
      return 'milestone';
    default:
      return 'class_update';
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

List<T> _parseList<T>(
  String body,
  T Function(Map<String, dynamic>) fromJson,
) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! List) {
    throw FormatException('Invalid list payload.');
  }
  return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

List<ClassRecipientSummary> parseClassRecipientsBody(String body) =>
    _parseList(body, ClassRecipientSummary.fromJson);

List<ParentSearchItem> parseParentSearchBody(String body) =>
    _parseList(body, ParentSearchItem.fromJson);

List<RecentMessageItem> parseRecentMessagesBody(String body) =>
    _parseList(body, RecentMessageItem.fromJson);
