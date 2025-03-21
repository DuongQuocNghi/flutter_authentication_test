import 'package:flutter/material.dart';

enum PasswordStrength { weak, medium, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final bool showFeedback;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.showFeedback = false,
  });

  PasswordStrength _calculateStrength() {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Add points for length
    if (password.length >= 8) {
      score += 1;
    }
    if (password.length >= 12) {
      score += 1;
    }

    // Add points for complexity
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    }

    // Subtract points for common patterns
    final commonPasswords = [
      'password',
      'qwerty',
      '123456',
      'admin',
      'welcome',
      'password123',
      'qwerty123',
    ];
    if (commonPasswords.contains(password.toLowerCase())) {
      score -= 3;
    }

    if (score < 3) {
      return PasswordStrength.weak;
    } else if (score < 5) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }

  String? _getFeedback() {
    if (!showFeedback) {
      return null;
    }

    if (password.length < 8) {
      return 'Password is too short';
    }

    final commonPasswords = [
      'password',
      'qwerty',
      '123456',
      'admin',
      'welcome',
      'password123',
      'qwerty123',
    ];
    if (commonPasswords.contains(password.toLowerCase())) {
      return 'This is a commonly used password';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Add uppercase letters';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Add lowercase letters';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Add numbers';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Add special characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final feedback = _getFeedback();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      key: const Key('strength_indicator_1'),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getColorForStrength(strength, 0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      key:
                          strength == PasswordStrength.weak
                              ? null
                              : const Key('strength_indicator_2'),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getColorForStrength(strength, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      key:
                          strength == PasswordStrength.strong
                              ? const Key('strength_indicator_3')
                              : null,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getColorForStrength(strength, 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getLabelForStrength(strength),
              style: TextStyle(
                color: _getTextColorForStrength(strength),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (feedback != null) ...[
          const SizedBox(height: 4),
          Text(
            feedback,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorForStrength(PasswordStrength strength, int position) {
    switch (strength) {
      case PasswordStrength.weak:
        return position == 0 ? Colors.red : Colors.grey.shade300;
      case PasswordStrength.medium:
        return position < 2 ? Colors.orange : Colors.grey.shade300;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  Color _getTextColorForStrength(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getLabelForStrength(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}
