import 'package:task_manager/features/auth/models/user_model.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;

  LoginRequested({
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    required this.isForce,
    required this.isSwitch,
  });
}

class SelectAccount extends AuthEvent {
  final UserModel account;

  SelectAccount(this.account);
}

class SessionExpired extends AuthEvent {
  final String message;

  SessionExpired({this.message = 'Session expired. Please login again.'});
}


// OTP Events
class RequestOtp extends AuthEvent {
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;

  RequestOtp({
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}

class VerifyOtpAndForceLogin extends AuthEvent {
  final String otp;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;

  VerifyOtpAndForceLogin({
    required this.otp,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}class LogoutRequested extends AuthEvent {}
