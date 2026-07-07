import 'dart:convert';

class ParentInboxMessage {
  final int id;
  final String kind;
  final String title;
  final String body;
  final String teacherName;
  final String messageType;
  final String messageTypeLabel;
  final String timeLabel;
  final bool isClassMessage;
  final String? childName;

  const ParentInboxMessage({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.teacherName,
    required this.messageType,
    required this.messageTypeLabel,
    required this.timeLabel,
    required this.isClassMessage,
    this.childName,
  });

  factory ParentInboxMessage.fromJson(Map<String, dynamic> json) {
    return ParentInboxMessage(
      id: _asInt(json['id']),
      kind: (json['kind'] as String?) ?? 'teacher_message',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      teacherName: (json['teacher_name'] as String?) ?? 'Teacher',
      messageType: (json['message_type'] as String?) ?? 'class_update',
      messageTypeLabel: (json['message_type_label'] as String?) ?? 'Update',
      timeLabel: (json['time_label'] as String?) ?? '',
      isClassMessage: json['is_class_message'] == true,
      childName: json['child_name'] as String?,
    );
  }

  static List<ParentInboxMessage> listFromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(ParentInboxMessage.fromJson).toList();
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
