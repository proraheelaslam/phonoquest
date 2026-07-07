import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'teacher_messages_models.dart';

class TeacherMessagesRepository {
  TeacherMessagesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<ClassRecipientSummary>> fetchClassRecipients() async {
    final res = await _client.get('/messages/classes', authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseClassRecipientsBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load classes.'),
    );
  }

  Future<List<ParentSearchItem>> searchIndividualRecipients({String query = ''}) async {
    final q = Uri.encodeQueryComponent(query.trim());
    final path = query.trim().isEmpty
        ? '/messages/individual/search'
        : '/messages/individual/search?q=$q';
    final res = await _client.get(path, authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseParentSearchBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not search parents.'),
    );
  }

  Future<List<RecentMessageItem>> fetchRecentMessages({int limit = 10}) async {
    final res = await _client.get('/messages/recent?limit=$limit', authorized: true);
    if (res.statusCode == 200) {
      try {
        return parseRecentMessagesBody(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not load recent messages.'),
    );
  }

  Future<void> sendClassMessage({
    required int classId,
    required String messageType,
    required String message,
  }) async {
    final res = await _client.postJson(
      '/messages/class',
      {
        'class_id': classId,
        'message_type': messageType,
        'message': message.trim(),
      },
      authorized: true,
    );
    if (res.statusCode == 201) return;
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not send message.'),
    );
  }

  Future<IndividualMessageResult> sendIndividualMessage({
    required int studentId,
    required String messageType,
    required String message,
  }) async {
    final res = await _client.postJson(
      '/messages/individual',
      {
        'student_id': studentId,
        'message_type': messageType,
        'message': message.trim(),
      },
      authorized: true,
    );
    if (res.statusCode == 201) {
      try {
        return IndividualMessageResult.fromRootJson(res.body);
      } on FormatException {
        throw ApiException(res.statusCode, 'Invalid response from server.');
      }
    }
    throw ApiException(
      res.statusCode,
      parseApiErrorBody(res.body, fallback: 'Could not send message.'),
    );
  }
}
