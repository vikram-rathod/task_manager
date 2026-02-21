import 'package:task_manager/features/auth/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;
  AuthLoading(this.message);
}

/// Used ONLY during account switch from home screen.
/// Preserves currentUser so the AppBar never goes blank.
class AuthSwitching extends AuthState {
  final UserModel currentUser;
  final String message;
  AuthSwitching({required this.currentUser, this.message = 'Switching account…'});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthMultipleAccountsFound extends AuthState {
  final List<UserModel> accounts;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  // NEW: carries the flag and the pre-switch user so the sheet can highlight them
  final bool isSwitch;
  final UserModel? currentUser;

  AuthMultipleAccountsFound({
    required this.accounts,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    this.isSwitch = false,
    this.currentUser,
  });
}

class LoggedInAnotherDevice extends AuthState {
  final String message;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;
  final int? selectedUserId;

  LoggedInAnotherDevice({
    required this.message,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    required this.isForce,
    required this.isSwitch,
    this.selectedUserId,
  });
}

class OtpSentSuccess extends AuthState {
  final String message;
  OtpSentSuccess(this.message);
}

class OtpError extends AuthState {
  final String message;
  OtpError(this.message);
}

class OtpVerifiedSuccess extends AuthState {
  final String message;
  OtpVerifiedSuccess(this.message);
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isMultipleAccounts;

  AuthAuthenticated({
    required this.user,
    required this.isMultipleAccounts,
  });
}

class AuthSessionExpired extends AuthState {
  final String message;
  AuthSessionExpired(this.message);
}
