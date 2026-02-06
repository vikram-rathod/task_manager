
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
  final bool isSwitch;
  final bool isForce;

  AccountSelected({required this.selectedAccount,required this.isSwitch, this.isForce = false });
}

class SessionCheckRequested extends AuthEvent {}

class RequestOtpEvent extends AuthEvent {
  final String email;

  RequestOtpEvent({required this.email});
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;
  final int? selectedUserId;




  VerifyOtpEvent({
    required this.email,
    required this.otp,
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

class LogoutRequested extends AuthEvent {
  final String sessionId;

  LogoutRequested({required this.sessionId});
}
