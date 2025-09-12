import 'package:flutter/material.dart';

import '../../../../../core/utils/validators.dart';
import '../../../presentation/widgets/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: nameController,
          hintText: 'Full Name',
          prefixIcon: const Icon(Icons.person_outline),
          validator: Validators.validateName,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          hintText: 'Password',
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (value) => Validators.validateConfirmPassword(
            passwordController.text,
            value,
          ),
        ),
      ],
    );
  }
}