import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/AllTasks/screens/all_task_screen.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/home/screens/profile_page.dart';

import '../../../animations/header_text_animation.dart';
import '../../../core/device/device_info_service.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../auth/dialogs/multi_account_dialog.dart';
import '../../createtask/screen/create_task_screen.dart';
import 'home_dash_board_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboardPage(),
    const AllTaskScreen(),
    const ProfilePage(),
  ];

  void showMultiAccountSheet(
      BuildContext context,
      List<UserModel> accounts,
      UserModel? currentUser,
      Function(UserModel) onSelected,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
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
          final currentState = context.read<AuthBloc>().state;
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
        final bool showSwitchAccount =
            state is AuthAuthenticated && state.isMultipleAccounts;
        // Get user info if authenticated
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }
        // Build UI here
        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Row(
                children: [
                  if (user != null)
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(user.userProfileUrl),
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
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
                    child: Column(
                      key: ValueKey(user?.designation),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "TASK ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: "MANAGER",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        HeaderTextAnimation(
                          designation: user!.designation,
                          companyText: user.companyName.isEmpty
                              ? user.userName
                              : "${user.companyName} • ${user.companyType}",
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 120,
                          height: 0.5,
                          color: const Color(0xFFB5E5B6),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
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
                        final deviceInfo =
                        await DeviceInfoService.getDeviceInfo();
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
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt),
                label: 'All Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
              );
            },
            child: const Icon(Icons.task_alt_outlined),
          ),
        );
      },
    );
  }
}