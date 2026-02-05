import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

import '../../../core/theme/theme_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            actions: [
              Row(
                  children: [
                    // Toggle Button
                    IconButton(
                      icon: const Icon(Icons.brightness_6),
                      onPressed: () {
                        context.read<ThemeCubit>().toggle();
                      },
                    ),
                    // Log-out Button
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        if (state is AuthAuthenticated) {
                          final UserModel user = state.user;
                          context.read<AuthBloc>().add(LogoutRequested(
                            sessionId: user.loginSessionId,
                          ));
                        }
                      },
                    )
                  ]
              )
            ],
          ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                final UserModel user = state.user;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome, ${user.userName}",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Email: ${user.userEmail}"),
                      Text("Mobile: ${user.userMobileNumber}"),
                      Text("Company: ${user.companyName}"),
                      Text("Designation: ${user.designation}"),
                      const SizedBox(height: 20),
                      Text("Session ID: ${user.loginSessionId}",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }
              // Session Expired
              if (state is AuthSessionExpired) {
                Navigator.pushReplacementNamed(context, '/login');
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}
