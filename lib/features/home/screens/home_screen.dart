import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/AllTasks/screens/all_task_screen.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/home/screens/home_app_bar.dart';
import 'package:task_manager/features/profile/profile_page.dart';

import '../../../core/di/injection_container.dart';
import '../../AllTasks/bloc/all_task_bloc.dart';
import '../../auth/dialogs/multi_account_dialog.dart';
import '../bloc/home_state.dart';
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
    final scheme = Theme
        .of(context)
        .colorScheme;

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

      builder: (context, authState) {

        final bool showSwitchAccount =
            authState is AuthAuthenticated && authState.isMultipleAccounts;

        UserModel? user;
        if (authState is AuthAuthenticated) {
          user = authState.user;
        }

        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
          previous.notificationCount != current.notificationCount,
          builder: (context, homeState) {
            print("UI notificationCount: ${homeState.notificationCount}");

            return Scaffold(
              appBar: HomeAppBar(
                user: user,
                showSwitchAccount: showSwitchAccount,
                state: authState,
                notificationCount: homeState.notificationCount,
              ),
              body: IndexedStack(
              index: _currentIndex,
              children: List.generate(3, (index) => _buildPage(index)),
            ),
              bottomNavigationBar: HomeBottomNav(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
              floatingActionButton: const HomeFab(),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
            );
          },
        );
      },
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeDashboardPage();

      case 1:
        return BlocProvider(
          create: (_) => AllTaskBloc(sl(), sl())
            ..add(LoadAllTasks()),
          child: const AllTaskScreen(),
        );

      case 2:
        return const ProfileScreen();

      default:
        return const HomeDashboardPage();
    }
  }
}
