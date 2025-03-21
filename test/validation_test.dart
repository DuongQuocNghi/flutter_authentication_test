import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthService authService;

  setUp(() async {
    // Thiết lập các dependencies cần thiết
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final client = http.Client();

    authService = AuthService(client: client, prefs: prefs);
  });

  group('Email validation', () {
    test('Email hợp lệ không gây lỗi', () {
      expect(authService.validateEmail('user@example.com'), isNull);
      expect(authService.validateEmail('test.user@domain.co.uk'), isNull);
      expect(authService.validateEmail('user+tag@gmail.com'), isNull);
    });

    test('Email trống gây lỗi', () {
      final result = authService.validateEmail('');
      expect(result, isNotNull);
      expect(result, contains('Email cannot be empty'));
    });

    test('Email không đúng định dạng gây lỗi', () {
      expect(authService.validateEmail('user@'), isNotNull);
      expect(authService.validateEmail('user@domain'), isNotNull);
      expect(authService.validateEmail('user.domain.com'), isNotNull);
      expect(authService.validateEmail('@domain.com'), isNotNull);
    });
  });

  group('Password validation', () {
    test('Mật khẩu hợp lệ không gây lỗi', () {
      expect(authService.validatePassword('Passw0rd123'), isNull);
      expect(authService.validatePassword('StrongP@ssw0rd'), isNull);
    });

    test('Mật khẩu trống gây lỗi', () {
      final result = authService.validatePassword('');
      expect(result, isNotNull);
      expect(result, contains('Password cannot be empty'));
    });

    test('Mật khẩu quá ngắn gây lỗi', () {
      final result = authService.validatePassword('Pass1');
      expect(result, isNotNull);
      expect(result, contains('Password must be at least 8 characters'));
    });

    test('Mật khẩu không có chữ hoa gây lỗi', () {
      final result = authService.validatePassword('password123');
      expect(result, isNotNull);
      expect(
        result,
        contains('Password must contain at least one uppercase letter'),
      );
    });

    test('Mật khẩu không có chữ thường gây lỗi', () {
      final result = authService.validatePassword('PASSWORD123');
      expect(result, isNotNull);
      expect(
        result,
        contains('Password must contain at least one lowercase letter'),
      );
    });

    test('Mật khẩu không có số gây lỗi', () {
      final result = authService.validatePassword('PasswordTest');
      expect(result, isNotNull);
      expect(result, contains('Password must contain at least one number'));
    });

    test('Mật khẩu phổ biến gây lỗi', () {
      final result = authService.validatePassword('Password123');
      expect(result, isNotNull);
      expect(result, contains('This is a commonly used password'));
    });

    test('Mật khẩu quá dài gây lỗi', () {
      final veryLongPassword = 'P' + 'a' * 5000 + '1';
      final result = authService.validatePassword(veryLongPassword);
      expect(result, isNotNull);
      expect(result, contains('Password is too long'));
    });
  });
}
