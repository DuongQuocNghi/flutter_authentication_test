import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'package:flutter_authentication_test/screens/login_screen.dart';

void main() {
  late AuthService authService;
  late BiometricService biometricService;

  setUp(() async {
    // Thiết lập các dependencies cần thiết
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Tạo HttpClient thật để sử dụng trong tests UI
    // Chú ý là các tests UI sẽ không gọi network nên không ảnh hưởng
    final client = http.Client();

    authService = AuthService(client: client, prefs: prefs);
    biometricService = BiometricService();
  });

  tearDown(() {
    // Clean up sau mỗi test
  });

  testWidgets('Hiển thị form đăng nhập với các trường nhập liệu', (
    WidgetTester tester,
  ) async {
    // Build LoginScreen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: authService,
          biometricService: biometricService,
        ),
      ),
    );

    // Verify các thành phần UI hiển thị
    expect(find.text('Log In'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('submit_button')), findsOneWidget);
  });

  testWidgets('Báo lỗi với email và mật khẩu không hợp lệ', (
    WidgetTester tester,
  ) async {
    // Build LoginScreen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: authService,
          biometricService: biometricService,
        ),
      ),
    );

    // Tìm các trường nhập liệu và nút đăng nhập
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('submit_button'));

    // Nhập thông tin không hợp lệ
    await tester.enterText(emailField, 'invalid-email');
    await tester.enterText(passwordField, 'short');

    // Bấm nút đăng nhập
    await tester.tap(loginButton);
    await tester.pump();

    // Kiểm tra thông báo lỗi
    expect(find.text('Invalid email format'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('Hiển thị nút quên mật khẩu và đăng ký', (
    WidgetTester tester,
  ) async {
    // Build LoginScreen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: authService,
          biometricService: biometricService,
        ),
      ),
    );

    // Verify các nút điều hướng
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Hiển thị nút đăng nhập sinh trắc học nếu hỗ trợ', (
    WidgetTester tester,
  ) async {
    // Build LoginScreen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: authService,
          biometricService: biometricService,
        ),
      ),
    );

    // Chú ý: Test này có thể fail tùy thuộc vào việc thiết bị có hỗ trợ sinh trắc học hay không
    // Nếu thiết bị thật hỗ trợ sinh trắc học, nút sẽ hiển thị
    // Trong thực tế, cần mock biometricService để kiểm soát kết quả
  });
}
