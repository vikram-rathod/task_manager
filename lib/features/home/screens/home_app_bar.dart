import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/device/device_info_service.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/home/screens/title_section.dart';

import '../../../reusables/logout_confirmation.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final bool showSwitchAccount;
  final AuthState state;
  final int notificationCount;

  const HomeAppBar({
    super.key,
    required this.user,
    required this.showSwitchAccount,
    required this.state,
    this.notificationCount = 0, // Default to 0
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Row(
              children: [
                if (user != null)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: user!.userProfileUrl.isNotEmpty
                            ? NetworkImage(user!.userProfileUrl)
                            : const AssetImage('assets/images/app_logo.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if(user != null)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: TitleSection(
                        key: ValueKey(user?.designation),
                        user: user!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            // Notification Icon with Badge
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.notifications_outlined),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          notificationCount > 99 ? '99+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Menu Dropdown
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.pushNamed(context, '/profile');
                    break;
                  case 'theme':
                    context.read<ThemeCubit>().toggle();
                    break;
                  case 'switch':
                    _handleSwitchAccount(context);
                    break;
                  case 'logout':
                    _showLogoutConfirmation(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;

                return [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Profile",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isDark ? 'Light Mode' : 'Dark Mode',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (showSwitchAccount)
                    PopupMenuItem<String>(
                      value: 'switch',
                      child: Row(
                        children: [
                          Icon(
                            Icons.switch_account,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Switch Account',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        Divider(
          color: scheme.primary.withAlpha(
            scheme.brightness == Brightness.dark ? 100 : 60,
          ),
          thickness: 1,
          height: 1
        ),
      ],
    );
  }

  Future<void> _handleSwitchAccount(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final repo = authBloc.repo;
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    final creds = await repo.getLastLoginCredentials();

    if (!context.mounted) return;

    if (creds == null ||
        creds["username"] == null ||
        creds["password"] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to retrieve login credentials"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) {
        return LogoutConfirmationDialog(
          onConfirm: () {
            if (state is AuthAuthenticated) {
              final user = (state as AuthAuthenticated).user;
              context.read<AuthBloc>().add(
                LogoutRequested(sessionId: user.loginSessionId),
              );
            }
          },
        );
      },
    );
  }

}
