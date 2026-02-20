import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/AllTasks/screens/all_task_screen.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/home/screens/home_app_bar.dart';
import 'package:task_manager/features/profile/profile_page.dart';

import '../../../core/di/injection_container.dart';
import '../../AllTasks/bloc/all_task_bloc.dart';
import '../../auth/auth_flow_handler.dart';
import '../../home/bloc/home_state.dart';
import '../../home/screens/home_bottom_nav.dart';
import '../../home/screens/home_dash_board_page.dart';
import '../../home/screens/home_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, AuthFlowHandler {

  @override
  bool get isHomeContext => true;

  int _currentIndex = 0;

  /// Cached user so the AppBar never goes blank during loading/switching states.
  UserModel? _cachedUser;

  UserModel? _userFrom(AuthState state) {
    if (state is AuthAuthenticated) {
      _cachedUser = state.user;
      return state.user;
    }
    if (state is AuthSwitching) {
      _cachedUser = state.currentUser;
      return state.currentUser;
    }
    if (state is AuthMultipleAccountsFound) {
      // currentUser may be null if this is a fresh login multi-account flow
      final user = state.currentUser ?? _cachedUser;
      if (user != null) _cachedUser = user;
      return _cachedUser;
    }
    // AuthLoading, AuthError, or any other transient state — keep showing last known user
    return _cachedUser;
  }

  bool _showSwitchFrom(AuthState state) =>
      state is AuthAuthenticated && state.isMultipleAccounts;

  bool _isSwitching(AuthState state) =>
      state is AuthSwitching ||
          state is AuthMultipleAccountsFound ||
          // Show the switching spinner in AppBar while the API call is in-flight
          // during an account switch (AuthLoading is also emitted on fresh login,
          // but _cachedUser being non-null is a reliable signal we're on home).
          (state is AuthLoading && _cachedUser != null);

  @override
  Widget build(BuildContext context) {
    return buildAuthListener(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = _userFrom(authState);
          final showSwitch = _showSwitchFrom(authState);
          final switching = _isSwitching(authState);

          return BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, cur) =>
            prev.notificationCount != cur.notificationCount,
            builder: (context, homeState) {
              return Scaffold(
                appBar: HomeAppBar(
                  user: user,
                  showSwitchAccount: showSwitch,
                  isSwitching: switching,
                  notificationCount: homeState.notificationCount,
                ),
                body: IndexedStack(
                  index: _currentIndex,
                  children: List.generate(3, _buildPage),
                ),
                bottomNavigationBar: HomeBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index == 0 && _currentIndex != 0) {
                      context.read<HomeBloc>().add(RefreshHomeData());
                    }
                    setState(() => _currentIndex = index);
                  },
                ),
                floatingActionButton: const HomeFab(),
                floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeDashboardPage();
      case 1:
        return BlocProvider(
          create: (_) => AllTaskBloc(sl(), sl())..add(LoadAllTasks()),
          child: const AllTaskScreen(),
        );
      case 2:
        return const ProfileScreen();
      default:
        return const HomeDashboardPage();
    }
  }
}