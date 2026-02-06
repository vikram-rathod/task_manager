import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

import '../../../core/device/device_info_service.dart';
import '../../../core/theme/theme_cubit.dart';
import '../dialogs/multi_account_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void showMultiAccountSheet(BuildContext context,
      List<UserModel> accounts,
      UserModel? currentUser,
      Function(UserModel) onSelected,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: MultiAccountSheet(
              accounts: accounts,
              currentUser: currentUser,
              onAccountSelected: onSelected,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle navigation here
        if (state is AuthSessionExpired) {
          debugPrint("[HomeScreen] Session expired - navigating to Login");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (route) => false);
        }

        if (state is AuthMultipleAccountsFound) {
          debugPrint("[HomeScreen] Multiple accounts found - showing sheet");

          UserModel? currentUser;
          final currentState = context
              .read<AuthBloc>()
              .state;
          if (currentState is AuthAuthenticated) {
            currentUser = currentState.user;
          }

          showMultiAccountSheet(
            context,
            state.accounts,
            currentUser,
                (account) {
              debugPrint("[HomeScreen] Account selected: ${account.userName}");
              context.read<AuthBloc>().add(
                AccountSelected(
                  selectedAccount: account,
                  isSwitch: true,
                  isForce: false,
                ),
              );
            },
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

      },
      builder: (context, state) {
        final bool showSwitchAccount = state is AuthAuthenticated &&
            state.isMultipleAccounts;
        // Get user info if authenticated
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }
        // Build UI here
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.userName ?? "Home",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.designation ?? "",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
                if (user != null)
                  Text(
                    "${user.companyName} • ${user.companyType}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
            actions: [
              Row(
                children: [
                  // Session ID info button
                  if (user != null)
                    IconButton(
                      tooltip: "Session: ${user.loginSessionId}",
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: const Text("User Information"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow("Username:", user!.userName),
                                    const SizedBox(height: 8),
                                    _buildInfoRow("Company:", user.companyName),
                                    const SizedBox(height: 8),
                                    _buildInfoRow("Type:", user.companyType),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                        "Session ID:", user.loginSessionId),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  // Toggle Button
                  IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: () {
                      context.read<ThemeCubit>().toggle();
                    },
                  ),
                  // Switch Account
                  if (showSwitchAccount)
                    IconButton(
                      tooltip: "Switch Account",
                      icon: const Icon(Icons.switch_account),
                      onPressed: () async {
                        debugPrint(
                            "[HomeScreen] Switch account button pressed");
                        final authBloc = context.read<AuthBloc>();
                        final repo = authBloc.repo;
                        final deviceInfo = await DeviceInfoService
                            .getDeviceInfo();
                        final creds = await repo.getLastLoginCredentials();

                        if (creds == null ||
                            creds["username"] == null ||
                            creds["password"] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Unable to retrieve login credentials"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Trigger login request to fetch multiple accounts
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            username: creds["username"]!,
                            password: creds["password"]!,
                            deviceName: deviceInfo.deviceName,
                            deviceType: deviceInfo.deviceType,
                            deviceUniqueId: deviceInfo.deviceUniqueId,
                            deviceToken: deviceInfo.deviceToken,
                            isSwitch: true,
                            isForce: false,
                          ),
                        );
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
                ],
              )
            ],
          ),
          body: const Center(
            child: Text("Welcome to Home Screen"),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}