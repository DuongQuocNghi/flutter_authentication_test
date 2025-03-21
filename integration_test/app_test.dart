import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_authentication_test/main.dart' as app;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';

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

  group('Kiểm tra luồng đăng nhập', () {
    testWidgets('Đăng nhập thành công và chuyển đến trang chủ', (
      WidgetTester tester,
    ) async {
      // Khởi tạo ứng dụng với services đã mock
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Kiểm tra xem màn hình đăng nhập đã xuất hiện chưa
      expect(find.text('Log In'), findsOneWidget);

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
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Đăng nhập thất bại hiển thị thông báo lỗi', (
      WidgetTester tester,
    ) async {
      // Khởi tạo ứng dụng với services đã mock
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Kiểm tra xem màn hình đăng nhập đã xuất hiện chưa
      expect(find.text('Log In'), findsOneWidget);

      // Tìm các trường nhập liệu và nút đăng nhập
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('submit_button'));

      // Nhập thông tin đăng nhập sai
      await tester.enterText(emailField, 'wrong@example.com');
      await tester.enterText(passwordField, 'WrongPassword1');

      // Nhấn nút đăng nhập
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Kiểm tra thông báo lỗi xuất hiện
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });
  });

  group('Kiểm tra luồng đăng ký', () {
    testWidgets('Đăng ký thành công và chuyển về trang đăng nhập', (
      WidgetTester tester,
    ) async {
      // Khởi tạo ứng dụng với services đã mock
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tìm nút đăng ký và nhấn
      final registerButton = find.byKey(const Key('register_button'));
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Kiểm tra xem màn hình đăng ký đã xuất hiện chưa
      expect(find.text('Create Account'), findsOneWidget);

      // Tìm các trường nhập liệu
      final formFields = find.byType(TextFormField);
      expect(
        formFields,
        findsAtLeast(3),
      ); // Ít nhất 3 trường (name, email, password)

      // Nhập thông tin đăng ký
      await tester.enterText(formFields.first, 'New User');
      await tester.enterText(formFields.at(1), 'new@example.com');
      await tester.enterText(formFields.at(2), 'NewPassword123');

      // Tìm nút submit đăng ký
      final submitButton = find.byKey(const Key('submit_button'));

      // Nhấn nút đăng ký
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Kiểm tra xem đã chuyển đến màn hình Login chưa
      expect(find.text('Log In'), findsOneWidget);
    });
  });

  group('Kiểm tra luồng quên mật khẩu', () {
    testWidgets('Gửi yêu cầu đặt lại mật khẩu thành công', (
      WidgetTester tester,
    ) async {
      // Khởi tạo ứng dụng với services đã mock
      await tester.pumpWidget(
        MaterialApp(
          home: app.MyApp(
            authService: authService,
            biometricService: biometricService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tìm nút quên mật khẩu và nhấn
      final forgotPasswordButton = find.byKey(
        const Key('forgot_Password_Button'),
      );
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Kiểm tra xem màn hình quên mật khẩu đã xuất hiện chưa
      expect(find.text('Forgot Password'), findsOneWidget);

      // Tìm trường nhập email
      final emailField = find.byType(TextFormField).first;

      // Nhập email
      await tester.enterText(emailField, 'test@example.com');

      // Tìm nút gửi
      final submitButton = find.byType(ElevatedButton).first;

      // Nhấn nút gửi
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Kiểm tra thông báo xác nhận xuất hiện
      expect(
        find.textContaining('Password reset email sent. Check your inbox.'),
        findsOneWidget,
      );
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
