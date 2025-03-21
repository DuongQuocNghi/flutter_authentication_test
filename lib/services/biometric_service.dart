import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'biometric_email');
      final password = await _secureStorage.read(key: 'biometric_password');
      return email != null && password != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      if (!await isBiometricAvailable()) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Xác thực để đăng nhập',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'biometric_email', value: email);
    await _secureStorage.write(key: 'biometric_password', value: password);
  }

  Future<Map<String, String>> getCredentials() async {
    final email = await _secureStorage.read(key: 'biometric_email') ?? '';
    final password = await _secureStorage.read(key: 'biometric_password') ?? '';
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'biometric_email');
    await _secureStorage.delete(key: 'biometric_password');
  }
}
