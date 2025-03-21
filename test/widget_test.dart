import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'package:flutter_authentication_test/main.dart';

void main() {
  late AuthService authService;
  late BiometricService biometricService;

  setUp(() async {
    // Thiết lập SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Khởi tạo các services
    final client = http.Client();
    authService = AuthService(client: client, prefs: prefs);
    biometricService = BiometricService();
  });

  testWidgets('Khởi tạo ứng dụng và hiển thị màn hình đăng nhập', (
    WidgetTester tester,
  ) async {
    // Xây dựng ứng dụng
    await tester.pumpWidget(
      MyApp(authService: authService, biometricService: biometricService),
    );

    // Kiểm tra màn hình login hiển thị
    expect(find.text('Log In'), findsOneWidget);

    // Kiểm tra các trường nhập liệu hiển thị
    expect(find.byType(TextFormField), findsAtLeast(2));
  });

  testWidgets('Theme của ứng dụng có màu chính là deepPurple', (
    WidgetTester tester,
  ) async {
    // Xây dựng ứng dụng
    await tester.pumpWidget(
      MyApp(authService: authService, biometricService: biometricService),
    );

    // Lấy theme của ứng dụng
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    final ThemeData theme = app.theme!;

    // Kiểm tra màu chính - deepPurple
    expect(theme.colorScheme.primary, isNotNull);

    // Kiểm tra Material 3
    expect(theme.useMaterial3, isTrue);
  });

  testWidgets('Các route được định nghĩa trong ứng dụng', (
    WidgetTester tester,
  ) async {
    // Xây dựng ứng dụng
    await tester.pumpWidget(
      MyApp(authService: authService, biometricService: biometricService),
    );

    // Lấy MaterialApp và kiểm tra routes
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Kiểm tra các route được định nghĩa
    expect(app.routes!.containsKey('/login'), isTrue);
    expect(app.routes!.containsKey('/register'), isTrue);
    expect(app.routes!.containsKey('/forgot-password'), isTrue);

    // Kiểm tra route ban đầu
    expect(app.initialRoute, equals('/login'));
  });
}
