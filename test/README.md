# Hướng dẫn chạy Unit Test

File này hướng dẫn cách chạy unit test cho ứng dụng Flutter Authentication.

## Cấu trúc thư mục test

Thư mục `test` chứa các file test sau:

- `auth_service_test.dart`: Test cho AuthService với các hàm đăng nhập, đăng ký.
- `login_screen_test.dart`: Test Widget cho màn hình đăng nhập.
- `validation_test.dart`: Test các hàm validation cho email và mật khẩu.
- `widget_test.dart`: Test Widget chung cho ứng dụng.

## Chạy tất cả các test

Để chạy tất cả các test:

```bash
flutter test
```

## Chạy từng file test

Để chạy một file test cụ thể:

```bash
flutter test test/auth_service_test.dart
flutter test test/validation_test.dart
flutter test test/login_screen_test.dart
flutter test test/widget_test.dart
```

## Chạy test với coverage

Để chạy test và tạo báo cáo coverage:

```bash
flutter test --coverage
```

Báo cáo coverage sẽ được tạo trong thư mục `coverage/lcov.info`. Để xem báo cáo dạng HTML, bạn cần cài đặt lcov:

```bash
# Cài đặt lcov (trên macOS)
brew install lcov

# Chuyển đổi báo cáo sang HTML
genhtml coverage/lcov.info -o coverage/html

# Mở báo cáo HTML
open coverage/html/index.html
```

## Ghi chú quan trọng

1. **MockHttpClient**: Trong file `auth_service_test.dart`, chúng ta đã tạo một `TestHttpClient` đơn giản để mô phỏng các API response mà không gọi đến server thật.

2. **Kiểm tra UI**: Các test trong `login_screen_test.dart` và `widget_test.dart` kiểm tra cấu trúc UI, không kiểm tra các tương tác mạng.

3. **BiometricService**: Test cho BiometricService hiện bị bỏ qua vì cần cấu hình chi tiết để mock các phụ thuộc nền tảng.

4. **SharedPreferences**: Chúng ta sử dụng `SharedPreferences.setMockInitialValues({})` để tạo một phiên bản giả của SharedPreferences cho mục đích test.

## Nhược điểm và cải tiến

1. Cần cải thiện cách mock các dependency cho BiometricService.
2. Thêm integration test để kiểm tra luồng hoàn chỉnh của ứng dụng.
3. Bổ sung test cho các màn hình khác (RegisterScreen, ForgotPasswordScreen, HomeScreen).
4. Tách riêng logic business khỏi UI để dễ dàng test hơn. 