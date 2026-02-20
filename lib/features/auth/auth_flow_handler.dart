import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/dialogs/multi_account_dialog.dart';
import 'package:task_manager/features/auth/dialogs/otp_verification_dialog.dart';

mixin AuthFlowHandler<T extends StatefulWidget> on State<T> {
  bool get isHomeContext => false;

  bool _otpSheetOpen = false;
  bool _multiAccountSheetOpen = false;

  Widget buildAuthListener({required Widget child}) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: child,
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _onAuthenticated(context, state);
      return;
    }
    if (state is AuthSessionExpired) {
      _onSessionExpired(context, state);
      return;
    }
    if (state is AuthMultipleAccountsFound) {
      _showMultiAccountSheet(context, state);
      return;
    }
    if (state is LoggedInAnotherDevice) {
      _showOtpSheet(context, state);
      return;
    }
    if (state is AuthError) {
      // Multi-account sheet handles AuthError inline via its own BlocListener.
      // Only show snackbar when the sheet is NOT open.
      if (!_multiAccountSheetOpen) {
        _showErrorSnackbar(context, state.message);
      }
      return;
    }
    // ─────────────────────────────────────────────────────────────────────────
    // IMPORTANT: Do NOT handle AuthLoading / AuthSwitching here by popping the
    // multi-account sheet. The sheet manages switching status internally now.
    // Popping on AuthLoading was the root cause of the sheet closing immediately
    // the moment an account was tapped.
    // ─────────────────────────────────────────────────────────────────────────
  }

  void _onAuthenticated(BuildContext context, AuthAuthenticated state) {
    if (!isHomeContext) {
      // Show a welcome snackbar on the login screen before navigating.
      final name = state.user.userName.isNotEmpty
          ? state.user.userName
          : state.user.userEmail;
      _showInfoSnackbar(
        context,
        message: 'Welcome back, $name!',
        color: Colors.green.shade600,
        icon: Icons.check_circle_outline_rounded,
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        }
      });
    }
    // On home: BlocBuilder rebuilds automatically.
    // The multi-account sheet handles AuthAuthenticated via its own BlocListener.
  }

  void _onSessionExpired(BuildContext context, AuthSessionExpired state) {
    // Determine whether this is a voluntary logout or a real session expiry
    // by checking the message the bloc emits:
    //   LogoutRequested  → "Session Expired...Log out Successfully."
    //   session check    → "Session expired. Please login again."
    //                    → "Not a valid session. Please login again."
    final isLogout = state.message.toLowerCase().contains('log out');
    final snackMessage = isLogout
        ? 'You have been logged out successfully.'
        : 'Your session has expired. Please log in again.';
    final snackColor = isLogout ? Colors.green.shade600 : Colors.orange.shade700;
    final snackIcon = isLogout ? Icons.logout_rounded : Icons.timer_off_rounded;

    _showInfoSnackbar(context,
        message: snackMessage, color: snackColor, icon: snackIcon);

    if (isHomeContext) {
      // Small delay so the snackbar is briefly visible before the screen is replaced.
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      });
    }
  }

  void _showMultiAccountSheet(
      BuildContext context,
      AuthMultipleAccountsFound state,
      ) {
    if (_multiAccountSheetOpen) return;
    _multiAccountSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: MultiAccountSheet(
          accounts: state.accounts,
          currentUser: state.currentUser,
          isSwitch: state.isSwitch,
          // Pass credentials so the sheet can retry the fetch itself
          username: state.username,
          password: state.password,
          deviceName: state.deviceName,
          deviceType: state.deviceType,
          deviceUniqueId: state.deviceUniqueId,
          deviceToken: state.deviceToken,
          onAccountSelected: (account) {
            // Dispatch ONLY — do NOT pop here.
            // Sheet shows switching/success/failed status inline.
            // On AuthAuthenticated → _onAuthenticated navigates and
            // dismisses all sheets automatically.
            context.read<AuthBloc>().add(AccountSelected(
              selectedAccount: account,
              isSwitch: state.isSwitch,
            ));
          },
        ),
      ),
    ).whenComplete(() {
      _multiAccountSheetOpen = false;
      if (!mounted) return;

      final currentState = context.read<AuthBloc>().state;

      // Only reset when sheet was closed mid-flight (back button / close tap).
      // If closed due to successful navigation, state is AuthAuthenticated — leave it.
      if (currentState is AuthMultipleAccountsFound ||
          currentState is AuthLoading ||
          currentState is AuthSwitching) {
        if (isHomeContext) {
          final restoredUser = currentState is AuthMultipleAccountsFound
              ? currentState.currentUser
              : currentState is AuthSwitching
              ? currentState.currentUser
              : null;

          if (restoredUser != null) {
            context.read<AuthBloc>().add(RestoreAuthenticatedUser(
              user: restoredUser,
              isMultipleAccounts: true,
            ));
          } else {
            context.read<AuthBloc>().add(ResetAuthState());
          }
        } else {
          context.read<AuthBloc>().add(ResetAuthState());
        }
      }
    });
  }

  void _showOtpSheet(BuildContext context, LoggedInAnotherDevice state) {
    if (_otpSheetOpen) return;
    _otpSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: OtpVerificationSheet(
          email: state.username,
          username: state.username,
          password: state.password,
          deviceName: state.deviceName,
          deviceType: state.deviceType,
          deviceUniqueId: state.deviceUniqueId,
          deviceToken: state.deviceToken,
          isSwitch: state.isSwitch,
          selectedUserId: state.selectedUserId,
        ),
      ),
    ).whenComplete(() {
      _otpSheetOpen = false;
      if (!mounted) return;
      final currentState = context.read<AuthBloc>().state;
      if (currentState is LoggedInAnotherDevice ||
          currentState is AuthLoading) {
        context.read<AuthBloc>().add(ResetAuthState());
      }
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showInfoSnackbar(
      BuildContext context, {
        required String message,
        required Color color,
        required IconData icon,
      }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}