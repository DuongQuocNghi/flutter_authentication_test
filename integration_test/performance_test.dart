import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_authentication_test/main.dart' as app;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'dart:typed_data';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late BiometricService biometricService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final client = _MockHttpClient();

    authService = AuthService(client: client, prefs: prefs);
    biometricService = BiometricService();
  });

  group('Kiểm tra hiệu suất', () {
    testWidgets('Đo thời gian đăng nhập và hiển thị màn hình chính', (
      WidgetTester tester,
    ) async {
      // Khai báo binding cho việc tính toán hiệu suất
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      // Khởi tạo ứng dụng
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Bắt đầu đo thời gian
      await binding.traceAction(() async {
        // Tìm các trường nhập liệu và nút đăng nhập
        final emailField = find.byKey(const Key('email_field'));
        final passwordField = find.byKey(const Key('password_field'));
        final loginButton = find.byKey(const Key('submit_button'));

        // Nhập thông tin đăng nhập
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'Passw0rd123');

        // Nhấn nút đăng nhập
        await tester.tap(loginButton);

        // Đợi cho đến khi giao diện ổn định
        await tester.pumpAndSettle();

        // Kiểm tra xem đã chuyển đến màn hình chính chưa
        expect(find.text('Welcome'), findsOneWidget);
      }, reportKey: 'login_performance');
    });

    testWidgets('Đo thời gian chuyển đổi giữa các màn hình', (
      WidgetTester tester,
    ) async {
      // Khai báo binding cho việc tính toán hiệu suất
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      // Khởi tạo ứng dụng
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Đo thời gian chuyển từ màn hình đăng nhập sang màn hình đăng ký
      await binding.traceAction(() async {
        // Tìm nút đăng ký
        final registerButton = find.byKey(const Key('register_button'));

        // Nhấn nút đăng ký
        await tester.tap(registerButton);

        // Đợi cho đến khi giao diện ổn định
        await tester.pumpAndSettle();

        // Kiểm tra xem đã chuyển đến màn hình đăng ký chưa
        expect(find.text('Create Account'), findsOneWidget);
      }, reportKey: 'navigation_to_register_screen');
    });

    testWidgets('Đo thời gian xử lý validation form', (
      WidgetTester tester,
    ) async {
      // Khai báo binding cho việc tính toán hiệu suất
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      // Khởi tạo ứng dụng
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Đo thời gian xử lý validation form
      await binding.traceAction(() async {
        // Tìm nút đăng nhập
        final loginButton = find.byKey(const Key('submit_button'));

        // Nhấn nút đăng nhập mà không nhập gì
        await tester.tap(loginButton);

        // Đợi cho đến khi giao diện ổn định và hiển thị thông báo lỗi
        await tester.pumpAndSettle();

        // Kiểm tra xem có hiển thị thông báo lỗi không
        expect(find.byType(TextFormField), findsAtLeast(2));
      }, reportKey: 'form_validation_performance');
    });
  });
}

// Mock HttpClient cho integration test
class _MockHttpClient implements http.Client {
  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    encoding,
  }) async {
    if (url.path.endsWith('/login')) {
      final requestBody = body.toString();
      if (requestBody.contains('test@example.com') &&
          requestBody.contains('Passw0rd123')) {
        return http.Response('''{
          "token": "test_token",
          "user": {
            "id": "1",
            "email": "test@example.com",
            "name": "Test User"
          }
        }''', 200);
      } else {
        return http.Response('{"error":"Invalid credentials"}', 401);
      }
    } else if (url.path.endsWith('/register')) {
      return http.Response('''{
        "token": "test_token",
        "user": {
          "id": "2",
          "email": "new@example.com",
          "name": "New User"
        }
      }''', 201);
    } else if (url.path.endsWith('/reset-password-request')) {
      return http.Response('''{
        "success": true,
        "message": "Password reset email sent"
      }''', 200);
    }

    return http.Response('{"error":"Unknown endpoint"}', 404);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.path.endsWith('/user-profile')) {
      return http.Response('''{
        "user": {
          "id": "1",
          "email": "test@example.com",
          "name": "Test User"
        }
      }''', 200);
    }

    return http.Response('{"error":"Unknown endpoint"}', 404);
  }

  @override
  void close() {}

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    encoding,
  }) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    encoding,
  }) async {
    return http.Response('{"error":"Not implemented"}', 501);
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    encoding,
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
