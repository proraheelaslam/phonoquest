import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'parent_dashboard_models.dart';
import 'parent_link_models.dart';
import 'parent_resources_models.dart';
import 'parent_status_models.dart';

class ParentDashboardRepository {
  ParentDashboardRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<ParentDashboardPayload> fetchDashboard() async {
    final response = await _client.get('/dashboard/parent', authorized: true);

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load parent dashboard.'),
      );
    }

    try {
      return ParentDashboardPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ParentRecentQuestsPayload> fetchRecentQuests({int limit = 50}) async {
    final response = await _client.get(
      '/dashboard/parent/recent-quests',
      authorized: true,
      queryParameters: {'limit': '$limit'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load recent quests.'),
      );
    }

    try {
      return ParentRecentQuestsPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ParentStatusPayload> fetchStatus() async {
    final response = await _client.get('/dashboard/parent/status', authorized: true);

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load parent status.'),
      );
    }

    try {
      return ParentStatusPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ChildLinkResult> linkChild({
    required String questCode,
    String? childDisplayName,
  }) async {
    final response = await _client.postJson(
      '/dashboard/parent/link-child',
      {
        'quest_code': questCode.trim(),
        if (childDisplayName != null && childDisplayName.trim().isNotEmpty)
          'child_display_name': childDisplayName.trim(),
      },
      authorized: true,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not link child account.'),
      );
    }

    try {
      return ChildLinkResult.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ChildLinkVerifyResult> verifyChildLink(String code) async {
    final trimmed = code.trim();
    final response = await _client.get(
      '/dashboard/parent/verify-child-link',
      authorized: true,
      queryParameters: {'code': trimmed},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not verify child link.'),
      );
    }

    try {
      return ChildLinkVerifyResult.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ParentResourcesPayload> fetchResources({
    String tab = 'all',
    String? query,
  }) async {
    final q = query?.trim();
    final response = await _client.get(
      '/dashboard/parent/resources',
      authorized: true,
      queryParameters: {
        'tab': tab,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load resources.'),
      );
    }

    try {
      return ParentResourcesPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
