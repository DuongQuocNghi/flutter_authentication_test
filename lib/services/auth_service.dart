import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/models/user.dart';
import 'package:flutter_authentication_test/models/auth_result.dart';
import 'package:flutter_authentication_test/utils/exceptions.dart';

class AuthService {
  static const String baseUrl = 'https://api.example.com';
  final http.Client client;
  final SharedPreferences prefs;
  User? currentUser;

  AuthService({required this.client, required this.prefs});

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          if (data['requires_mfa'] == true) {
            return AuthResult.requireMfa(data['mfa_session_token']);
          }

          if (!data.containsKey('token')) {
            throw FormatException('The server response is missing token');
          }

          final token = data['token'];
          final user = User.fromJson(data['user']);

          final success = await prefs.setString('auth_token', token);
          if (!success) {
            throw StorageException('Failed to store authentication token');
          }

          currentUser = user;
          return AuthResult(user, token);

        case 401:
          throw AuthException('Invalid credentials');
        case 423:
          throw AccountLockedException('Account temporarily locked');
        case 429:
          throw RateLimitException('Too many requests');
        case 500:
        default:
          throw NetworkException('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      String message = 'Network error';
      if (e.message.contains('timed out')) {
        message = 'Connection timed out. Please try again.';
      } else if (e.message.contains('Failed host lookup')) {
        message = 'No internet connectivity. Please check your connection.';
      }
      throw NetworkException(message);
    } catch (e) {
      if (e is AuthException ||
          e is NetworkException ||
          e is FormatException ||
          e is StorageException ||
          e is RateLimitException ||
          e is AccountLockedException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      switch (response.statusCode) {
        case 201:
          final data = json.decode(response.body);
          final token = data['token'];
          final user = User.fromJson(data['user']);

          await prefs.setString('auth_token', token);
          currentUser = user;
          return AuthResult(user, token);

        case 409:
          throw AuthException('Email already in use');
        case 422:
          final data = json.decode(response.body);
          final Map<String, List<String>> errors = {};

          if (data.containsKey('errors')) {
            (data['errors'] as Map<String, dynamic>).forEach((key, value) {
              if (value is List) {
                errors[key] = List<String>.from(value);
              } else {
                errors[key] = [value.toString()];
              }
            });
          }

          throw ValidationException(errors);
        default:
          throw NetworkException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await prefs.remove('auth_token');
    currentUser = null;
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/reset-password-request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw AuthException('Failed to request password reset');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token, 'password': newPassword}),
      );

      if (response.statusCode == 400) {
        throw AuthException('Invalid or expired token');
      } else if (response.statusCode != 200) {
        throw NetworkException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<String> refreshToken() async {
    final oldToken = prefs.getString('auth_token');
    if (oldToken == null) {
      throw AuthException('Not logged in');
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Authorization': 'Bearer $oldToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        await prefs.setString('auth_token', newToken);
        return newToken;
      } else {
        throw AuthException('Invalid refresh token');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Failed to refresh token: ${e.toString()}');
    }
  }

  Future<AuthResult> verifyMfa(String mfaSessionToken, String mfaCode) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/verify-mfa'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mfa_session_token': mfaSessionToken,
          'mfa_code': mfaCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await prefs.setString('auth_token', token);
        currentUser = user;
        return AuthResult(user, token);
      } else {
        throw AuthException('Invalid MFA code');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Failed to verify MFA: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithGoogle(String? googleToken) async {
    if (googleToken == null) {
      throw AuthCancelledException();
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': googleToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await prefs.setString('auth_token', token);
        currentUser = user;
        return AuthResult(user, token);
      } else {
        throw AuthException('Google authentication failed');
      }
    } catch (e) {
      if (e is AuthException || e is AuthCancelledException) {
        rethrow;
      }
      throw NetworkException('Failed to sign in with Google: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithApple(String? appleToken) async {
    if (appleToken == null) {
      throw AuthCancelledException();
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/apple'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': appleToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await prefs.setString('auth_token', token);
        currentUser = user;
        return AuthResult(user, token);
      } else {
        throw AuthException('Apple authentication failed');
      }
    } catch (e) {
      if (e is AuthException || e is AuthCancelledException) {
        rethrow;
      }
      throw NetworkException('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  Future<User> getUserProfile() async {
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw AuthException('Not logged in');
    }

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user-profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        currentUser = user;
        return user;
      } else if (response.statusCode == 401) {
        try {
          // Try to refresh token
          await refreshToken();
          // Retry with new token
          return getUserProfile();
        } catch (e) {
          // If refresh token fails, session is expired
          throw SessionExpiredException();
        }
      } else {
        throw NetworkException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException ||
          e is NetworkException ||
          e is SessionExpiredException) {
        rethrow;
      }
      throw NetworkException('Failed to get user profile: ${e.toString()}');
    }
  }

  // Validation methods
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }

    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for common passwords
    final commonPasswords = [
      'password123',
      'qwerty123',
      '12345678',
      'Password123',
    ];

    if (commonPasswords.contains(password)) {
      return 'This is a commonly used password';
    }

    if (password.length > 5000) {
      return 'Password is too long';
    }

    return null;
  }
}
