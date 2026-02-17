import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/AllTasks/screens/all_task_screen.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/home/screens/home_app_bar.dart';
import 'package:task_manager/features/profile/profile_page.dart';

import '../../../animations/header_text_animation.dart';
import '../../../core/device/device_info_service.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../auth/dialogs/multi_account_dialog.dart';
import '../../createtask/screen/create_task_screen.dart';
import 'home_bottom_nav.dart';
import 'home_dash_board_page.dart';
import 'home_fab.dart';

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
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }

        if (state is AuthMultipleAccountsFound) {
          debugPrint("[HomeScreen] Multiple accounts found - showing sheet");

          UserModel? currentUser;
          final currentState = context.read<AuthBloc>().state;
          if (currentState is AuthAuthenticated) {
            currentUser = currentState.user;
          }

          showMultiAccountSheet(context, state.accounts, currentUser, (
            account,
          ) {
            debugPrint("[HomeScreen] Account selected: ${account.userName}");
            context.read<AuthBloc>().add(
              AccountSelected(
                selectedAccount: account,
                isSwitch: true,
                isForce: false,
              ),
            );
          });
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
          appBar: HomeAppBar(
            user: user,
            showSwitchAccount: showSwitchAccount,
            state: state,
            notificationCount: 5, 
          ),
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: HomeBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          floatingActionButton: const HomeFab(),
        );
      },
    );
  }
}
