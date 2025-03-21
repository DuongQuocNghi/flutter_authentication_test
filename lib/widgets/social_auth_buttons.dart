import 'package:flutter/material.dart';
import 'package:flutter_authentication_test/services/auth_service.dart';
import 'package:flutter_authentication_test/models/auth_result.dart';
import 'package:flutter_authentication_test/utils/exceptions.dart';

class SocialAuthButtons extends StatefulWidget {
  final AuthService authService;
  final Function(AuthResult) onSuccess;

  const SocialAuthButtons({
    super.key,
    required this.authService,
    required this.onSuccess,
  });

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // In a real app, you would implement Google Sign-In and get a token
      // For the test, we'll simulate a successful sign-in
      final googleToken = 'mock-google-token';
      final result = await widget.authService.signInWithGoogle(googleToken);

      if (mounted) {
        widget.onSuccess(result);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } on AuthCancelledException {
      // User cancelled the sign-in, no error message needed
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to sign in with Google: $e';
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

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // In a real app, you would implement Apple Sign-In and get a token
      // For the test, we'll simulate a successful sign-in
      final appleToken = 'mock-apple-token';
      final result = await widget.authService.signInWithApple(appleToken);

      if (mounted) {
        widget.onSuccess(result);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } on AuthCancelledException {
      // User cancelled the sign-in, no error message needed
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to sign in with Apple: $e';
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

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // This would be implemented in a real app
      // For now, we'll just show a not implemented message
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _errorMessage = 'Facebook sign-in not implemented';
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
        else ...[
          ElevatedButton.icon(
            key: const Key('google_sign_in'),
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Continue with Google'),
            onPressed: _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key('apple_sign_in'),
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
            onPressed: _handleAppleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 1,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key('facebook_sign_in'),
            icon: const Icon(Icons.facebook),
            label: const Text('Continue with Facebook'),
            onPressed: _handleFacebookSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              elevation: 1,
            ),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
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
