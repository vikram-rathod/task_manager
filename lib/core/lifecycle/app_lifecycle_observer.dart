import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';

import '../../features/home/bloc/home_bloc.dart';



class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({required this.child, super.key});

  @override
  State<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint(" Lifecycle Observer Attached");
  }

  @override
  void dispose() {
    debugPrint(" Lifecycle Observer Removed");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("APP STATE: $state");

    if (state == AppLifecycleState.resumed) {
      debugPrint("APP RESUMED");

      final authState = context.read<AuthBloc>().state;
      debugPrint("APP RESUMED → current auth state: ${authState.runtimeType}");

      //  Only check session if user is actually authenticated.
      // If they're on login screen (AuthInitial / AuthSessionExpired),
      // there's no session to validate — skip to avoid snackbar on login screen.
      if (authState is AuthAuthenticated || authState is AuthSwitching) {
        debugPrint("APP RESUMED → dispatching SessionCheckRequested");
        context.read<AuthBloc>().add(SessionCheckRequested());
      } else {
        debugPrint("APP RESUMED → skipping session check, not authenticated");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}