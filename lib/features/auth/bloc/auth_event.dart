import '../models/user_model.dart';

abstract class AuthEvent {}

// ─── Login ────────────────────────────────────────────────────────────────────

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
    this.isForce = false,
    this.isSwitch = false,
    this.selectedUserId,
  });
}

// ─── Account selection (after multi-account sheet) ────────────────────────────

class AccountSelected extends AuthEvent {
  final UserModel selectedAccount;
  /// True when switching from home screen, false when picking during login.
  final bool isSwitch;

  AccountSelected({required this.selectedAccount, required this.isSwitch});
}

// ─── Session ──────────────────────────────────────────────────────────────────

class SessionCheckRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {
  final String sessionId;
  LogoutRequested({required this.sessionId});
}

class ResetAuthState extends AuthEvent {}

/// Fired when the multi-account sheet is dismissed via back button on the
/// home screen — restores the previous AuthAuthenticated state so the AppBar
/// and switch button remain visible.
class RestoreAuthenticatedUser extends AuthEvent {
  final UserModel user;
  final bool isMultipleAccounts;
  RestoreAuthenticatedUser({required this.user, required this.isMultipleAccounts});
}

// ─── OTP ──────────────────────────────────────────────────────────────────────

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
    required this.isSwitch,
    this.selectedUserId,
  });
}