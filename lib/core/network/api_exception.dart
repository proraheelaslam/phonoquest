class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  ApiException(this.statusCode, this.message, {this.code});

  bool get isEmailNotVerified => code == 'EMAIL_NOT_VERIFIED';

  @override
  String toString() => message;
}
