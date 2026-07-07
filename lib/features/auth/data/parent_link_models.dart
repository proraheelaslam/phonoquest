import 'dart:convert';

class ChildLinkResult {
  final String childName;
  final String questCode;
  final bool childLinked;

  const ChildLinkResult({
    required this.childName,
    required this.questCode,
    required this.childLinked,
  });

  factory ChildLinkResult.fromJson(Map<String, dynamic> json) {
    return ChildLinkResult(
      childName: (json['child_name'] as String?) ?? '',
      questCode: (json['quest_code'] as String?) ?? '',
      childLinked: json['child_linked'] == true,
    );
  }

  static ChildLinkResult fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid child link payload.');
    }
    return ChildLinkResult.fromJson(data);
  }
}

class ChildLinkVerifyResult {
  final bool found;
  final String? childName;
  final String? questCode;
  final String? hint;

  const ChildLinkVerifyResult({
    required this.found,
    this.childName,
    this.questCode,
    this.hint,
  });

  factory ChildLinkVerifyResult.fromJson(Map<String, dynamic> json) {
    return ChildLinkVerifyResult(
      found: json['found'] == true,
      childName: json['child_name'] as String?,
      questCode: json['quest_code'] as String?,
      hint: json['hint'] as String?,
    );
  }

  static ChildLinkVerifyResult fromRootJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid response from server.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid child link verify payload.');
    }
    return ChildLinkVerifyResult.fromJson(data);
  }
}
