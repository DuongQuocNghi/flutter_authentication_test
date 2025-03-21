import 'package:flutter/material.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'package:flutter_authentication_test/widgets/biometric_auth_button.dart';
import 'package:flutter_authentication_test/widgets/social_auth_buttons.dart';
import 'package:flutter_authentication_test/screens/home_screen.dart';
import 'package:flutter_authentication_test/utils/exceptions.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final BiometricService? biometricService;

  const LoginScreen({
    Key? key,
    required this.authService,
    this.biometricService,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (result.requiresMfa) {
        if (mounted) {
          // Navigate to MFA screen (not implemented in this example)
          setState(() {
            _errorMessage = 'MFA required. Not implemented in this demo.';
            _isLoading = false;
          });
        }
        return;
      }

      if (widget.biometricService != null) {
        final canUseBiometrics =
            await widget.biometricService!.isBiometricAvailable();
        if (canUseBiometrics) {
          // Offer to save credentials for biometric login
          await widget.biometricService!.saveCredentials(
            _emailController.text,
            _passwordController.text,
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: result.user!)),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('login_screen'),
      appBar: AppBar(title: const Text('Log In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('email_field'),
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            widget.authService.validateEmail(value ?? ''),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('password_field'),
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        key: const Key('toggle_password_visibility'),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator:
                        (value) =>
                            widget.authService.validatePassword(value ?? ''),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        key: const Key('submit_button'),
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('LOG IN'),
                      ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              key: const Key('forgot_Password_Button'),
              onPressed: () {
                Navigator.of(context).pushNamed('/forgot-password');
              },
              child: const Text('Forgot Password?'),
            ),
            if (widget.biometricService != null) ...[
              const SizedBox(height: 24),
              BiometricAuthButton(
                authService: widget.authService,
                biometricService: widget.biometricService!,
                onSuccess: (result) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(user: result.user!),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            SocialAuthButtons(
              authService: widget.authService,
              onSuccess: (result) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(user: result.user!),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  key: const Key('register_button'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
