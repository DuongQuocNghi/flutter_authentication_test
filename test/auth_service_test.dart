import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/utils/exceptions.dart';

void main() {
  late AuthService authService;
  late _TestHttpClient mockClient;
  late SharedPreferences mockPrefs;

  setUp(() async {
    // Thiết lập SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();

    // Thiết lập Client mock
    mockClient = _TestHttpClient();

    // Khởi tạo AuthService
    authService = AuthService(client: mockClient, prefs: mockPrefs);
  });

  group('validateEmail', () {
    test('trả về null khi email hợp lệ', () {
      expect(authService.validateEmail('user@example.com'), isNull);
    });

    test('trả về lỗi khi email trống', () {
      expect(authService.validateEmail(''), isNotNull);
    });

    test('trả về lỗi khi email không đúng định dạng', () {
      expect(authService.validateEmail('invalid-email'), isNotNull);
    });
  });

  group('validatePassword', () {
    test('trả về null khi mật khẩu hợp lệ', () {
      expect(authService.validatePassword('Passw0rd123'), isNull);
    });

    test('trả về lỗi khi mật khẩu trống', () {
      expect(authService.validatePassword(''), isNotNull);
    });

    test('trả về lỗi khi mật khẩu quá ngắn', () {
      expect(authService.validatePassword('Pass1'), isNotNull);
    });

    test('trả về lỗi khi mật khẩu không có chữ hoa', () {
      expect(authService.validatePassword('password123'), isNotNull);
    });

    test('trả về lỗi khi mật khẩu không có chữ thường', () {
      expect(authService.validatePassword('PASSWORD123'), isNotNull);
    });

    test('trả về lỗi khi mật khẩu không có số', () {
      expect(authService.validatePassword('PasswordTest'), isNotNull);
    });

    test('trả về lỗi khi mật khẩu nằm trong danh sách phổ biến', () {
      expect(authService.validatePassword('password123'), isNotNull);
    });
  });

  group('login', () {
    test('đăng nhập thành công trả về AuthResult', () async {
      final result = await authService.login('test@example.com', 'Password123');

      expect(result.user, isNotNull);
      expect(result.token, equals('test_token'));
      expect(result.user!.email, equals('test@example.com'));
    });

    test('đăng nhập thất bại với thông tin không hợp lệ', () async {
      expect(
        () => authService.login('wrong@example.com', 'wrongpassword'),
        throwsA(isA<AuthException>()),
      );
    });

    test('yêu cầu MFA trả về kết quả với requiresMfa=true', () async {
      final result = await authService.login('mfa@example.com', 'anypassword');

      expect(result.requiresMfa, isTrue);
      expect(result.mfaSessionToken, equals('mfa_token_123'));
    });
  });

  group('register', () {
    test('đăng ký thành công trả về AuthResult', () async {
      final result = await authService.register(
        'New User',
        'new@example.com',
        'Password123',
      );

      expect(result.user, isNotNull);
      expect(result.token, equals('test_token'));
      expect(result.user!.name, equals('New User'));
    });

    test('đăng ký thất bại khi email đã tồn tại', () async {
      expect(
        () => authService.register(
          'Test User',
          'existing@example.com',
          'Password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}

// Một cách đơn giản hơn để tạo một HTTP client giả lập
class _TestHttpClient implements http.Client {
  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    if (url.path.endsWith('/login')) {
      final requestBody = json.decode(body.toString());

      if (requestBody['email'] == 'test@example.com' &&
          requestBody['password'] == 'Password123') {
        return http.Response(
          json.encode({
            'token': 'test_token',
            'user': {
              'id': '1',
              'email': 'test@example.com',
              'name': 'Test User',
            },
          }),
          200,
        );
      } else if (requestBody['email'] == 'mfa@example.com') {
        return http.Response(
          json.encode({
            'requires_mfa': true,
            'mfa_session_token': 'mfa_token_123',
          }),
          200,
        );
      } else {
        return http.Response('{"error":"Invalid credentials"}', 401);
      }
    } else if (url.path.endsWith('/register')) {
      final requestBody = json.decode(body.toString());

      if (requestBody['email'] == 'existing@example.com') {
        return http.Response('{"error":"Email already exists"}', 409);
      } else {
        return http.Response(
          json.encode({
            'token': 'test_token',
            'user': {
              'id': '1',
              'email': requestBody['email'],
              'name': requestBody['name'],
            },
          }),
          201,
        );
      }
    }

    return http.Response('{"error":"Unknown endpoint"}', 404);
  }

  @override
  void close() {}

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }
}
