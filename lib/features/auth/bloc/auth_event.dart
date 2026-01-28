import 'package:task_manager/features/auth/models/user_model.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  // Device fields (kept exactly as backend expects)
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;

  LoginRequested({
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}

class SelectAccount extends AuthEvent {
  final UserModel account;
  SelectAccount(this.account);
}

class LogoutRequested extends AuthEvent {}
