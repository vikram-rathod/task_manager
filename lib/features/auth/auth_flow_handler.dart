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

  String get _screen => isHomeContext ? 'HomeScreen' : 'LoginScreen';

  Widget buildAuthListener({required Widget child}) {
    debugPrint('[$_screen][AuthFlowHandler] buildAuthListener mounted');
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: child,
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    debugPrint('[$_screen][AuthFlowHandler] _handleState fired → ${state.runtimeType}');

    if (state is AuthAuthenticated) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthAuthenticated | isHomeContext=$isHomeContext | user=${state.user.userEmail}');
      _onAuthenticated(context, state);
      return;
    }
    if (state is AuthSessionExpired) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthSessionExpired | isHomeContext=$isHomeContext | message="${state.message}"');
      _onSessionExpired(context, state);
      return;
    }
    if (state is AuthMultipleAccountsFound) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthMultipleAccountsFound | accounts=${state.accounts.length} | sheetOpen=$_multiAccountSheetOpen');
      _showMultiAccountSheet(context, state);
      return;
    }
    if (state is LoggedInAnotherDevice) {
      debugPrint('[$_screen][AuthFlowHandler] → LoggedInAnotherDevice | sheetOpen=$_otpSheetOpen');
      _showOtpSheet(context, state);
      return;
    }
    if (state is AuthError) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthError | message="${state.message}" | multiAccountSheetOpen=$_multiAccountSheetOpen');
      if (!_multiAccountSheetOpen) {
        _showErrorSnackbar(context, state.message);
      } else {
        debugPrint('[$_screen][AuthFlowHandler] AuthError suppressed — multi-account sheet is open');
      }
      return;
    }
    if (state is AuthLoading) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthLoading | message="${state.message}" (ignored by handler)');
      return;
    }
    if (state is AuthSwitching) {
      debugPrint('[$_screen][AuthFlowHandler] → AuthSwitching (ignored by handler)');
      return;
    }

    debugPrint('[$_screen][AuthFlowHandler] → Unhandled state: ${state.runtimeType}');
  }

  void _onAuthenticated(BuildContext context, AuthAuthenticated state) {
    if (!isHomeContext) {
      debugPrint('[$_screen][AuthFlowHandler] _onAuthenticated → not home, will show snackbar then navigate to /home');
      final name = state.user.userName.isNotEmpty
          ? state.user.userName
          : state.user.userEmail;
      _showInfoSnackbar(
        context,
        message: 'Welcome back, $name!',
        color: Colors.green.shade600,
        icon: Icons.check_circle_outline_rounded,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        debugPrint('[$_screen][AuthFlowHandler] _onAuthenticated → navigating to /home now | mounted=$mounted');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        }
      });
    } else {
      debugPrint('[$_screen][AuthFlowHandler] _onAuthenticated → home context, BlocBuilder handles rebuild');
    }
  }

  void _onSessionExpired(BuildContext context, AuthSessionExpired state) {
    final isLogout = state.message.toLowerCase().contains('log out');
    debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired | isLogout=$isLogout | isHomeContext=$isHomeContext');

    final snackMessage = isLogout
        ? 'You have been logged out successfully.'
        : 'Your session has expired. Please log in again.';
    final snackColor = isLogout ? Colors.green.shade600 : Colors.orange.shade700;
    final snackIcon = isLogout ? Icons.logout_rounded : Icons.timer_off_rounded;

    debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired → showing snackbar: "$snackMessage"');
    _showInfoSnackbar(context, message: snackMessage, color: snackColor, icon: snackIcon);

    debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired → dispatching ResetAuthState immediately');
    context.read<AuthBloc>().add(ResetAuthState());

    if (isHomeContext) {
      debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired → scheduling navigation to /login in 600ms');
      Future.delayed(const Duration(milliseconds: 600), () {
        debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired → navigating to /login now | mounted=$mounted');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      });
    } else {
      debugPrint('[$_screen][AuthFlowHandler] _onSessionExpired → login screen, no navigation needed');
    }
  }

  void _showMultiAccountSheet(
      BuildContext context,
      AuthMultipleAccountsFound state,
      ) {
    if (_multiAccountSheetOpen) {
      debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → already open, skipping');
      return;
    }
    _multiAccountSheetOpen = true;
    debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → opening sheet');

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
          username: state.username,
          password: state.password,
          deviceName: state.deviceName,
          deviceType: state.deviceType,
          deviceUniqueId: state.deviceUniqueId,
          deviceToken: state.deviceToken,
          onAccountSelected: (account) {
            debugPrint('[$_screen][AuthFlowHandler] MultiAccountSheet → account selected: ${account.userEmail}');
            context.read<AuthBloc>().add(AccountSelected(
              selectedAccount: account,
              isSwitch: state.isSwitch,
            ));
          },
        ),
      ),
    ).whenComplete(() {
      debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → sheet closed (whenComplete)');
      _multiAccountSheetOpen = false;
      if (!mounted) {
        debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → not mounted, skipping cleanup');
        return;
      }

      final currentState = context.read<AuthBloc>().state;
      debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → state after close: ${currentState.runtimeType}');

      if (currentState is AuthMultipleAccountsFound ||
          currentState is AuthLoading ||
          currentState is AuthSwitching) {
        debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → mid-flight close detected, resetting');
        if (isHomeContext) {
          final restoredUser = currentState is AuthMultipleAccountsFound
              ? currentState.currentUser
              : currentState is AuthSwitching
              ? currentState.currentUser
              : null;

          if (restoredUser != null) {
            debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → restoring user: ${restoredUser.userEmail}');
            context.read<AuthBloc>().add(RestoreAuthenticatedUser(
              user: restoredUser,
              isMultipleAccounts: true,
            ));
          } else {
            debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → no user to restore, resetting');
            context.read<AuthBloc>().add(ResetAuthState());
          }
        } else {
          debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → login context, resetting');
          context.read<AuthBloc>().add(ResetAuthState());
        }
      } else {
        debugPrint('[$_screen][AuthFlowHandler] _showMultiAccountSheet → no reset needed, state is ${currentState.runtimeType}');
      }
    });
  }

  void _showOtpSheet(BuildContext context, LoggedInAnotherDevice state) {
    if (_otpSheetOpen) {
      debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → already open, skipping');
      return;
    }
    _otpSheetOpen = true;
    debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → opening sheet');

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
      debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → sheet closed (whenComplete)');
      _otpSheetOpen = false;
      if (!mounted) {
        debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → not mounted, skipping cleanup');
        return;
      }
      final currentState = context.read<AuthBloc>().state;
      debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → state after close: ${currentState.runtimeType}');
      if (currentState is LoggedInAnotherDevice || currentState is AuthLoading) {
        debugPrint('[$_screen][AuthFlowHandler] _showOtpSheet → mid-flight close, resetting');
        context.read<AuthBloc>().add(ResetAuthState());
      }
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!mounted) return;
    debugPrint('[$_screen][AuthFlowHandler] _showErrorSnackbar → "$message"');
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
    debugPrint('[$_screen][AuthFlowHandler] _showInfoSnackbar → "$message"');
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
