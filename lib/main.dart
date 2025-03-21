import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'package:flutter_authentication_test/screens/login_screen.dart';
import 'package:flutter_authentication_test/screens/register_screen.dart';
import 'package:flutter_authentication_test/screens/home_screen.dart';
import 'package:flutter_authentication_test/screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các dịch vụ
  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();

  final authService = AuthService(client: httpClient, prefs: sharedPreferences);

  final biometricService = BiometricService();

  runApp(MyApp(authService: authService, biometricService: biometricService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final BiometricService biometricService;

  const MyApp({
    super.key,
    required this.authService,
    required this.biometricService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Authentication Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login':
            (context) => LoginScreen(
              authService: authService,
              biometricService: biometricService,
            ),
        '/register': (context) => RegisterScreen(authService: authService),
        '/forgot-password':
            (context) => ForgotPasswordScreen(authService: authService),
      },
    );
  }
}
