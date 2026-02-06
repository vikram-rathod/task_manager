import 'package:task_manager/features/auth/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;

  AuthLoading(this.message);
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

  AuthMultipleAccountsFound({
    required this.accounts,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}

class LoggedInAnotherDevice extends AuthState{
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

  LoggedInAnotherDevice(
      {
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
      }
      );
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

