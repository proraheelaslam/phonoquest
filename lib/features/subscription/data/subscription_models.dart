import 'dart:convert';

Map<String, dynamic> _expectDataMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid subscription payload.');
  }
  return data;
}

List<Map<String, dynamic>> _expectDataList(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid response from server.');
  }
  final data = decoded['data'];
  if (data is! List) {
    throw const FormatException('Invalid subscription plans payload.');
  }
  return data.whereType<Map<String, dynamic>>().toList();
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class SubscriptionPlanCatalogItem {
  final int id;
  final String name;
  final String code;
  final String billingCycle;
  final double price;
  final String currency;
  final int trialDays;
  final bool isActive;
  final String priceLabel;
  final String billingSuffix;
  final String? badge;
  final String? saveText;
  final String description;
  final List<String> features;
  final List<String> lockedFeatures;

  const SubscriptionPlanCatalogItem({
    required this.id,
    required this.name,
    required this.code,
    required this.billingCycle,
    required this.price,
    required this.currency,
    required this.trialDays,
    required this.isActive,
    required this.priceLabel,
    required this.billingSuffix,
    this.badge,
    this.saveText,
    required this.description,
    required this.features,
    required this.lockedFeatures,
  });

  factory SubscriptionPlanCatalogItem.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    final locked = json['locked_features'];
    return SubscriptionPlanCatalogItem(
      id: _asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      billingCycle: (json['billing_cycle'] as String?) ?? 'monthly',
      price: _asDouble(json['price']),
      currency: (json['currency'] as String?) ?? 'USD',
      trialDays: _asInt(json['trial_days']),
      isActive: json['is_active'] == true,
      priceLabel: (json['price_label'] as String?) ?? '',
      billingSuffix: (json['billing_suffix'] as String?) ?? '',
      badge: json['badge'] as String?,
      saveText: json['save_text'] as String?,
      description: (json['description'] as String?) ?? '',
      features: features is List ? features.whereType<String>().toList() : const [],
      lockedFeatures: locked is List ? locked.whereType<String>().toList() : const [],
    );
  }

  static List<SubscriptionPlanCatalogItem> listFromRootJson(String body) {
    return _expectDataList(body).map(SubscriptionPlanCatalogItem.fromJson).toList();
  }
}

class SubscriptionMe {
  final String role;
  final String currentPlanCode;
  final String currentPlanName;
  final bool isPremium;
  final String? billingCycle;
  final double? price;
  final String? currency;
  final String? priceLabel;
  final bool canManage;
  final List<String> features;
  final List<String> lockedFeatures;
  final String? familyPlanLabel;
  final String? managedByLabel;
  final String? linkedChildName;
  final String? message;
  final bool? childLinked;
  final String? pendingCheckoutPlanCode;
  final String? pendingCheckoutPlanName;
  final bool paymentRequired;
  final bool inClass;
  final String? planManagedBy;

  const SubscriptionMe({
    required this.role,
    required this.currentPlanCode,
    required this.currentPlanName,
    required this.isPremium,
    this.billingCycle,
    this.price,
    this.currency,
    this.priceLabel,
    required this.canManage,
    required this.features,
    required this.lockedFeatures,
    this.familyPlanLabel,
    this.managedByLabel,
    this.linkedChildName,
    this.message,
    this.childLinked,
    this.pendingCheckoutPlanCode,
    this.pendingCheckoutPlanName,
    this.paymentRequired = false,
    this.inClass = false,
    this.planManagedBy,
  });

  factory SubscriptionMe.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    final locked = json['locked_features'];
    return SubscriptionMe(
      role: (json['role'] as String?) ?? 'student',
      currentPlanCode: (json['current_plan_code'] as String?) ?? 'basic',
      currentPlanName: (json['current_plan_name'] as String?) ?? 'Basic Access',
      isPremium: json['is_premium'] == true,
      billingCycle: json['billing_cycle'] as String?,
      price: json['price'] == null ? null : _asDouble(json['price']),
      currency: json['currency'] as String?,
      priceLabel: json['price_label'] as String?,
      canManage: json['can_manage'] == true,
      features: features is List ? features.whereType<String>().toList() : const [],
      lockedFeatures: locked is List ? locked.whereType<String>().toList() : const [],
      familyPlanLabel: json['family_plan_label'] as String?,
      managedByLabel: json['managed_by_label'] as String?,
      linkedChildName: json['linked_child_name'] as String?,
      message: json['message'] as String?,
      childLinked: json['child_linked'] as bool?,
      pendingCheckoutPlanCode: json['pending_checkout_plan_code'] as String?,
      pendingCheckoutPlanName: json['pending_checkout_plan_name'] as String?,
      paymentRequired: json['payment_required'] == true,
      inClass: json['in_class'] == true,
      planManagedBy: json['plan_managed_by'] as String?,
    );
  }

  factory SubscriptionMe.fromRootJson(String body) {
    return SubscriptionMe.fromJson(_expectDataMap(body));
  }
}

class SubscriptionCheckoutResult {
  final String transactionId;
  final String planCode;
  final String planName;
  final double amount;
  final String currency;
  final String priceLabel;
  final String billingSuffix;
  final String status;
  final String message;

  const SubscriptionCheckoutResult({
    required this.transactionId,
    required this.planCode,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.priceLabel,
    required this.billingSuffix,
    required this.status,
    required this.message,
  });

  factory SubscriptionCheckoutResult.fromRootJson(String body) {
    final data = _expectDataMap(body);
    return SubscriptionCheckoutResult(
      transactionId: (data['transaction_id'] as String?) ?? '',
      planCode: (data['plan_code'] as String?) ?? '',
      planName: (data['plan_name'] as String?) ?? '',
      amount: _asDouble(data['amount']),
      currency: (data['currency'] as String?) ?? 'USD',
      priceLabel: (data['price_label'] as String?) ?? '',
      billingSuffix: (data['billing_suffix'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'completed',
      message: (data['message'] as String?) ?? 'Payment completed.',
    );
  }
}
