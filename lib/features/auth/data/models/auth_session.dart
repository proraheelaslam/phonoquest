/// Successful `/auth/login` (or `/auth/register`) payload subset.
class AuthSession {
  final String accessToken;
  final String tokenType;
  final String? roleName;
  final String? email;
  final bool emailVerified;

  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    this.roleName,
    this.email,
    this.emailVerified = true,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'];
    if (token is! String || token.isEmpty) {
      throw FormatException('Missing access_token in auth response');
    }
    final rawType = json['token_type'];
    final type = rawType is String && rawType.isNotEmpty ? rawType : 'bearer';

    String? roleName;
    String? email;
    var emailVerified = true;
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final rawRole = user['role_name'];
      if (rawRole is String && rawRole.isNotEmpty) {
        roleName = rawRole;
      }
      final rawEmail = user['email'];
      if (rawEmail is String && rawEmail.isNotEmpty) {
        email = rawEmail;
      }
      final rawVerified = user['email_verified'];
      if (rawVerified is bool) {
        emailVerified = rawVerified;
      }
    }

    return AuthSession(
      accessToken: token,
      tokenType: type,
      roleName: roleName,
      email: email,
      emailVerified: emailVerified,
    );
  }
}
