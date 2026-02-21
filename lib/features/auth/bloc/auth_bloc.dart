import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/auth_request.dart';
import 'package:task_manager/features/auth/models/login_response.dart';
import 'package:task_manager/features/auth/models/user_model.dart';
import 'package:task_manager/features/auth/repository/auth_repository.dart';

import '../../utils/app_exception.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<SessionCheckRequested>(_sessionCheck);
    on<AccountSelected>(_onAccountSelected);
    on<RequestOtpEvent>(_requestOtp);
    on<VerifyOtpEvent>(_verifyOtp);
    on<LogoutRequested>(_logout);
    on<ResetAuthState>(_resetAuthState);
    on<RestoreAuthenticatedUser>(_restoreAuthenticatedUser);
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    debugPrint(
      "[_login] username=${event.username} isSwitch=${event.isSwitch} "
          "isForce=${event.isForce} selectedUserId=${event.selectedUserId}",
    );

    // ── Capture current user BEFORE emitting any loading state ──────────────
    // After we emit, state changes and we can no longer read the old user.
    UserModel? currentUser;
    if (state is AuthAuthenticated) {
      currentUser = (state as AuthAuthenticated).user;
    } else if (state is AuthSwitching) {
      currentUser = (state as AuthSwitching).currentUser;
    }

    // ── Emit appropriate loading state ───────────────────────────────────────
    // AuthSwitching keeps the user visible in the AppBar during a switch.
    // AuthLoading is for fresh login where there's no current user.
    if (event.isSwitch && currentUser != null) {
      emit(AuthSwitching(currentUser: currentUser, message: 'Switching account…'));
    } else {
      emit(AuthLoading("Checking account..."));
    }

    final request = AuthRequest(
      selectedUserId: event.selectedUserId,
      username: event.username,
      password: event.password,
      deviceName: event.deviceName,
      deviceType: event.deviceType,
      deviceUniqueId: event.deviceUniqueId,
      deviceToken: event.deviceToken,
      isForce: event.isForce,
      isSwitch: event.isSwitch,
      appType: "2",
    );

    debugPrint(
      "[_login] Request:\n${const JsonEncoder.withIndent('  ').convert(request.toJson())}",
    );

    try {
      final apiResponse = await repo.login(request);
      debugPrint(
        "[_login] Response: status=${apiResponse.status} msg='${apiResponse.message}'",
      );

      if (apiResponse.status) {
        final loginResponse = apiResponse.data as LoginResponse;

        if (loginResponse.isMulti) {
          debugPrint("[_login] Multiple accounts — emitting AuthMultipleAccountsFound "
              "(isSwitch=${event.isSwitch}, currentUser=${currentUser?.userName})");
          await repo.saveIsMultipleAccounts(true);
          emit(AuthMultipleAccountsFound(
            accounts: loginResponse.accountList,
            username: event.username,
            password: event.password,
            deviceName: event.deviceName,
            deviceType: event.deviceType,
            deviceUniqueId: event.deviceUniqueId,
            deviceToken: event.deviceToken,
            isSwitch: event.isSwitch,
            currentUser: currentUser, // ← key: passed in so sheet can highlight it
          ));
          return;
        }

        // Single account success
        final user = loginResponse.userInfo!;
        await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);
        await repo.saveLastLoginCredentials(
          username: event.username,
          password: event.password,
        );
        final isMultipleAccounts = await repo.getSavedIsMultipleAccounts();
        debugPrint("[_login] Authenticated as ${user.userName}");
        emit(AuthAuthenticated(user: user, isMultipleAccounts: isMultipleAccounts));

      } else {
        if (apiResponse.message == "Already Logged In on another device") {
          debugPrint("[_login] Already logged in on another device");
          emit(LoggedInAnotherDevice(
            message: apiResponse.message,
            username: event.username,
            password: event.password,
            deviceName: event.deviceName,
            deviceType: event.deviceType,
            deviceUniqueId: event.deviceUniqueId,
            deviceToken: event.deviceToken,
            isForce: event.isForce,
            isSwitch: event.isSwitch,
            selectedUserId: event.selectedUserId,
          ));
        } else {
          debugPrint("[_login] Login failed: ${apiResponse.message}");
          emit(AuthError(apiResponse.message));
        }
      }
    } catch (error) {
      debugPrint("[_login] Exception: ${error.toString()}");
      final exception = AppExceptionMapper.from(error);
      emit(AuthError(
        exception.message,
      ));
    }
  }

  void _onAccountSelected(AccountSelected event, Emitter<AuthState> emit) {
    if (state is! AuthMultipleAccountsFound) return;
    final current = state as AuthMultipleAccountsFound;

    add(LoginRequested(
      username: current.username,
      password: current.password,
      selectedUserId: event.selectedAccount.userId,
      deviceName: current.deviceName,
      deviceType: current.deviceType,
      deviceUniqueId: current.deviceUniqueId,
      deviceToken: current.deviceToken,
      isSwitch: event.isSwitch,
    ));
  }

  Future<void> _sessionCheck(
      SessionCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    debugPrint("[_sessionCheck] Checking session...");
    emit(AuthLoading("Checking session..."));
    try {
      final isValid = await repo.isSessionValid();
      if (isValid) {
        final user = await repo.getSavedUser();
        final isMultipleAccounts = await repo.getSavedIsMultipleAccounts();
        if (user != null) {
          emit(AuthAuthenticated(user: user, isMultipleAccounts: isMultipleAccounts));
        } else {
          emit(AuthSessionExpired("Not a valid session. Please login again."));
        }
      } else {
        emit(AuthSessionExpired("Session expired. Please login again."));
      }
    } catch (e) {
      final exception = AppExceptionMapper.from(e);
      emit(AuthError(
        exception.message,
      ));
    }
  }

  Future<void> _requestOtp(
      RequestOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    debugPrint("[_requestOtp] Requesting OTP for: ${event.email}");
    try {
      final apiResponse = await repo.requestOtp(event.email);
      if (apiResponse.status) {
        emit(OtpSentSuccess("OTP sent successfully"));
      } else {
        emit(OtpError(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : "Failed to send OTP"));
      }
    } catch (error) {
      debugPrint("[_requestOtp] Exception: ${error.toString()}");
      final exception = AppExceptionMapper.from(error);

      emit(OtpError(
        exception.message,
      ));
    }
  }

  Future<void> _verifyOtp(
      VerifyOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    debugPrint("[_verifyOtp] Verifying OTP for: ${event.email}");
    emit(AuthLoading("Verifying OTP..."));
    try {
      final apiResponse = await repo.verifyOtp(event.email, event.otp);
      if (apiResponse.status) {
        emit(OtpVerifiedSuccess(apiResponse.message));
        // Force-login after successful OTP
        add(LoginRequested(
          username: event.username,
          password: event.password,
          deviceName: event.deviceName,
          deviceType: event.deviceType,
          deviceUniqueId: event.deviceUniqueId,
          deviceToken: event.deviceToken,
          isForce: true,
          isSwitch: event.isSwitch,
          selectedUserId: event.selectedUserId,
        ));
      } else {
        emit(OtpError(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : "Invalid OTP. Please try again."));
      }
    } catch (error) {
      debugPrint("[_verifyOtp] Exception: ${error.toString()}");
      final exception = AppExceptionMapper.from(error);

      emit(OtpError(exception.message));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
    emit(AuthLoading("Logging out..."));
    await repo.logout(sessionId: event.sessionId);
    await repo.saveIsMultipleAccounts(false);
    emit(AuthSessionExpired("Session Expired...Log out Successfully."));
    } catch (e) {
      final exception = AppExceptionMapper.from(e);
      emit(AuthError(exception.message));
    }
  }

  FutureOr<void> _resetAuthState(
      ResetAuthState event,
      Emitter<AuthState> emit,
      ) {
    emit(AuthInitial());
  }

  FutureOr<void> _restoreAuthenticatedUser(
      RestoreAuthenticatedUser event,
      Emitter<AuthState> emit,
      ) {
    emit(AuthAuthenticated(
      user: event.user,
      isMultipleAccounts: event.isMultipleAccounts,
    ));
  }
}