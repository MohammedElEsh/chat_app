import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation/bloc/auth_bloc.dart';
import '../../../presentation/bloc/auth_state.dart';
import 'login_header.dart';
import 'login_form.dart';
import 'login_footer.dart';

class LoginViewBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  const LoginViewBody({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const LoginHeader(),
              const SizedBox(height: 48),
              LoginForm(
                emailController: emailController,
                passwordController: passwordController,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return LoginFooter(
                    onLoginPressed: onLoginPressed,
                    onRegisterPressed: onRegisterPressed,
                    isLoading: state is AuthLoading,
                  );
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}