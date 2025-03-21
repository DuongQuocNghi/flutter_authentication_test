import 'package:flutter/material.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/services/biometric_service.dart';
import 'package:flutter_authentication_test/models/auth_result.dart';
import 'package:flutter_authentication_test/utils/exceptions.dart';

class BiometricAuthButton extends StatefulWidget {
  final AuthService authService;
  final BiometricService biometricService;
  final Function(AuthResult) onSuccess;

  const BiometricAuthButton({
    super.key,
    required this.authService,
    required this.biometricService,
    required this.onSuccess,
  });

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final biometricsAvailable =
        await widget.biometricService.isBiometricAvailable();
    final hasSavedCredentials =
        await widget.biometricService.hasSavedCredentials();

    if (mounted) {
      setState(() {
        _isAvailable = biometricsAvailable && hasSavedCredentials;
      });
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authenticated = await widget.biometricService.authenticate();

      if (!authenticated) {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
          _isLoading = false;
        });
        return;
      }

      final credentials = await widget.biometricService.getCredentials();
      final result = await widget.authService.login(
        credentials['email']!,
        credentials['password']!,
      );

      if (mounted) {
        widget.onSuccess(result);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication failed: $e';
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
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.fingerprint),
            label: const Text('Login with Biometrics'),
            onPressed: _handleBiometricAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
