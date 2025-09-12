import 'package:flutter/material.dart';

import '../../../presentation/widgets/custom_button.dart';

class RegisterFooter extends StatelessWidget {
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;
  final bool isLoading;

  const RegisterFooter({
    super.key,
    required this.onRegisterPressed,
    required this.onLoginPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Register',
          onPressed: onRegisterPressed,
          isLoading: isLoading,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.grey[600]),
            ),
            GestureDetector(
              onTap: onLoginPressed,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C52FF), Color(0xFFC300FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white, // overridden by shader
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}