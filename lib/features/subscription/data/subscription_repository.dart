import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import 'student_access_models.dart';
import 'subscription_models.dart';

class SubscriptionRepository {
  SubscriptionRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<SubscriptionPlanCatalogItem>> fetchPublicPlans() async {
    final response = await _client.get('/subscriptions/plans/public', authorized: false);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load subscription plans.'),
      );
    }
    try {
      return SubscriptionPlanCatalogItem.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<List<SubscriptionPlanCatalogItem>> fetchPlans() async {
    final response = await _client.get('/subscriptions/plans', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load subscription plans.'),
      );
    }
    try {
      return SubscriptionPlanCatalogItem.listFromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<SubscriptionMe> fetchMe() async {
    final response = await _client.get('/subscriptions/me', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load your subscription.'),
      );
    }
    try {
      return SubscriptionMe.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<StudentAccess> fetchStudentAccess() async {
    final response = await _client.get('/student/access', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load your access settings.'),
      );
    }
    try {
      return StudentAccess.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<SubscriptionCheckoutResult> checkout(String planCode) async {
    final response = await _client.postJson(
      '/subscriptions/checkout',
      {'plan_code': planCode},
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not complete payment.'),
      );
    }
    try {
      return SubscriptionCheckoutResult.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<SubscriptionMe> changePlan(String planCode) async {
    final response = await _client.patchJson(
      '/subscriptions/plan',
      {'plan_code': planCode},
      authorized: true,
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not update subscription plan.'),
      );
    }
    try {
      return SubscriptionMe.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }
}
