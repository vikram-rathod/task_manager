
import '../models/user_model.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;
  final int? selectedUserId;


  LoginRequested({
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

class AccountSelected extends AuthEvent {
  final UserModel selectedAccount;

  AccountSelected({required this.selectedAccount});
}


class SessionCheckRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {
  final String sessionId;

  LogoutRequested({required this.sessionId});
}
