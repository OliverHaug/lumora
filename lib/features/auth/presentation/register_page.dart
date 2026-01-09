import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumora/core/providers/di_providers.dart';
import 'package:lumora/core/theme/app_colors.dart';
import 'package:lumora/features/auth/logic/register/register_bloc.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerBloc = ref.watch(registerBlocProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Create account')),
      body: BlocProvider.value(
        value: registerBloc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: BlocConsumer<RegisterBloc, RegisterState>(
            listener: (context, state) {
              if (state.status == RegisterStatus.success) {
                context.go('/community');
              }
            },
            builder: (context, state) {
              final isLoading = state.status == RegisterStatus.loading;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: (v) => registerBloc.add(RegisterEmailChanged(v)),
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onChanged: (v) =>
                        registerBloc.add(RegisterPasswordChanged(v)),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      helperText: 'Min. 8 characters',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onChanged: (v) =>
                        registerBloc.add(RegisterConfirmPasswordChanged(v)),
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      errorText:
                          (state.confirmPassword.isNotEmpty &&
                              !state.passwordsMatch)
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.status == RegisterStatus.failure &&
                      state.error != null) ...[
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => registerBloc.add(RegisterSubmitted()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffdec27a),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.black,
                          )
                        : const SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Create account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
