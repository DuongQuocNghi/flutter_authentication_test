# Integration Tests

Thư mục này chứa các integration tests cho ứng dụng Flutter Authentication. Integration tests kiểm tra toàn bộ ứng dụng hoạt động như một hệ thống.

## Cấu trúc

- **app_test.dart**: Kiểm tra đầy đủ các luồng xử lý chính của ứng dụng
- **driver.dart**: File điều khiển để chạy integration tests

## Các luồng xử lý được kiểm tra

1. **Luồng đăng nhập**:
   - Đăng nhập thành công và chuyển đến trang chủ
   - Đăng nhập thất bại hiển thị thông báo lỗi

2. **Luồng đăng ký**:
   - Đăng ký thành công và chuyển đến trang chủ

3. **Luồng quên mật khẩu**:
   - Gửi yêu cầu đặt lại mật khẩu thành công


## Cách chạy integration tests

### 1. Chạy trên máy ảo hoặc thiết bị

```bash
flutter test integration_test/app_test.dart
```

### 2. Chạy trên nhiều thiết bị cùng lúc

Sử dụng driver.dart để chạy tests trên nhiều thiết bị:

```bash
# Trên Android
flutter drive \
  --driver=integration_test/driver.dart \
  --target=integration_test/app_test.dart \
  -d <device_id>

# Trên iOS
flutter drive \
  --driver=integration_test/driver.dart \
  --target=integration_test/app_test.dart \
  -d <device_id>
```

### 3. Chạy tests hiệu suất

```bash
flutter test integration_test/performance_test.dart
```

## Kết quả

Khi chạy tests hiệu suất sử dụng `traceAction()`, kết quả hiệu suất sẽ được ghi lại trong `build/integration_response_data.json`. Bạn có thể xem chi tiết về thời gian thực hiện của từng hoạt động tại đó.

## Ghi chú

- Các tests này sử dụng classes mock cho http.Client và SharedPreferences để tránh gọi API thực tế.
- Trong môi trường CI/CD, có thể sử dụng driver.dart để tích hợp tests vào quy trình CI/CD. 