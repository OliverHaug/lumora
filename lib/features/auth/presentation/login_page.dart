import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/features/auth/logic/login/login_bloc.dart';
import 'package:xyz/features/auth/logic/login/login_event.dart';
import 'package:xyz/features/auth/logic/login/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginBloc = Get.find<LoginBloc>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: true,
        title: Text("Welcome back"),
      ),
      body: BlocProvider.value(
        value: loginBloc,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state.status == LoginStatus.success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Logged in')));
                  loginBloc.add(LoginReset());
                  Get.offAllNamed('/community');
                } else if (state.status == LoginStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error ?? 'Login failed')),
                  );

                  loginBloc.add(LoginReset());
                }
              },
              builder: (context, state) {
                final isLoading = state.status == LoginStatus.loading;

                return Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            onChanged: (v) =>
                                loginBloc.add(LoginEmailChanged(v)),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            onChanged: (v) =>
                                loginBloc.add(LoginPasswordChanged(v)),
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading ? null : () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 8,
                                ),
                                foregroundColor: Colors.black.withValues(
                                  alpha: .55,
                                ),
                              ),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => loginBloc.add(LoginSubmitted()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffdec27a),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.black,
                                        ),
                                      )
                                    : Text(
                                        "Log in",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(child: Divider(color: Colors.black12)),
                              Text("Or continue with"),
                              Expanded(child: Divider(color: Colors.black12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF5F1EA),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.g_mobiledata, size: 28),
                                Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Get.offNamed('/register'),
                      child: Text(
                        "Don't have an account? Sign up",
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
      ),
    );
  }
}
