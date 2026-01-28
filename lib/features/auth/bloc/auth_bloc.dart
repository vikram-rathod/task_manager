import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/auth_request.dart';
import 'package:task_manager/features/auth/models/login_response.dart';
import 'package:task_manager/features/auth/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<SelectAccount>(_selectAccount);
    on<LogoutRequested>(_logout);
  }

  LoginResponse? _cachedLoginResponse;

  void _logDivider(String title) {
    print("\n======================================");
    print(" $title");
    print("======================================");
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    _logDivider("LOGIN REQUEST STARTED");

    print("Username: ${event.username}");
    print("Device Name: ${event.deviceName}");
    print("Device Type: ${event.deviceType}");
    print("Device Unique ID: ${event.deviceUniqueId}");
    print("Device Token: ${event.deviceToken}");

    emit(AuthLoading("Checking account..."));

    final request = AuthRequest(
      username: event.username,
      password: event.password,
      deviceName: event.deviceName,
      deviceType: event.deviceType,
      deviceUniqueId: event.deviceUniqueId,
      deviceToken: event.deviceToken,
      isForce: false,
      isSwitch: false,
      appType: "2",
    );

    try {
      print("Calling Login API...");
      final loginResponse = await repo.login(request);

      print("Login API Response received");
      print("isMultiAccount: ${loginResponse.isMulti}");

      if (loginResponse.isMulti) {
        _cachedLoginResponse = loginResponse;

        print("Multiple accounts found: ${loginResponse.accountList.length}");
        for (var acc in loginResponse.accountList) {
          print("Account: ${acc.userName} | ${acc.userEmail}");
        }

        emit(AuthHasMultiAccount(
          message: "Multiple accounts found",
          accounts: loginResponse.accountList,
        ));
      } else {
        final user = loginResponse.userInfo!;
        print("Single account login: ${user.userName}");
        print("Company: ${user.companyName}");
        print("Session ID: ${user.loginSessionId}");

        await repo.saveUser(user);

        print("User saved to local storage");

        emit(AuthAuthenticated(user));
      }

      _logDivider("LOGIN REQUEST COMPLETED");
    } catch (error) {
      print("Login error: $error");
      _logDivider("LOGIN FAILED");
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _selectAccount(
      SelectAccount event, Emitter<AuthState> emit) async {
    _logDivider("MULTI-ACCOUNT SELECTION");

    print("Selected Account: ${event.account.userName}");
    print("Email: ${event.account.userEmail}");
    print("Company: ${event.account.companyName}");

    emit(AuthLoading("Signing into selected account..."));

    await repo.saveUser(event.account);

    print("Selected account saved locally");
    print("Session ID: ${event.account.loginSessionId}");

    emit(AuthAuthenticated(event.account));

    _logDivider("ACCOUNT SELECTION COMPLETED");
  }

  Future<void> _logout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    _logDivider("LOGOUT STARTED");

    emit(AuthLoading("Logging out..."));

    await repo.logout();

    print("Local storage cleared");
    print("User logged out successfully");

    emit(AuthInitial());

    _logDivider("LOGOUT COMPLETED");
  }
}
