import 'package:flutter_authentication_test/models/user.dart';

class AuthResult {
  final User? user;
  final String? token;
  final bool requiresMfa;
  final String? mfaSessionToken;

  AuthResult(
    this.user,
    this.token, {
    this.requiresMfa = false,
    this.mfaSessionToken,
  });

  factory AuthResult.requireMfa(String mfaSessionToken) {
    return AuthResult(
      null,
      null,
      requiresMfa: true,
      mfaSessionToken: mfaSessionToken,
    );
  }
}
