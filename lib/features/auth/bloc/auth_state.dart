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

  AuthHasMultiAccount({
    required this.message,
    required this.accounts,
  });
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}
