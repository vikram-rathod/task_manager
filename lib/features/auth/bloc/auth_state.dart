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

class AuthHasMultiAccount extends AuthState {
  final String message;
  final List<UserModel> accounts;

  AuthHasMultiAccount({required this.message, required this.accounts});
}

class AuthAlreadyLoggedIn extends AuthState {
  final String message;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;

  AuthAlreadyLoggedIn({
    required this.message,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}

class AuthOtpSent extends AuthState {
  final String message;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;

  AuthOtpSent({
    required this.message,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

class AuthSessionExpired extends AuthState {
  final String message;

  AuthSessionExpired(this.message);
}