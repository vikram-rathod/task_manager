import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
    on<SessionCheckRequested>(_sessionCheck);
    on<AccountSelected>(_onAccountSelected);
    on<RequestOtpEvent>(_requestOtp);
    on<VerifyOtpEvent>(_verifyOtp);
    on<LogoutRequested>(_logout);
    on<ResetAuthState>(_resetAuthState);

  }


  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    debugPrint("[_login] Start login process"
        "Name: ${event.username}, Password: ${event
        .password}, DeviceName: ${event.deviceName}, DeviceType: ${event
        .deviceType},"
        " DeviceUniqueId: ${event.deviceUniqueId}, DeviceToken: ${event
        .deviceToken}, isForce: ${event.isForce},"
        " isSwitch: ${event.isSwitch}, selectedUserId: ${event.selectedUserId}"
        "");

    emit(AuthLoading("Checking account..."));

    debugPrint("[_login] Emitted AuthLoading state");

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
        "[_login] AuthRequest prepared:\n${const JsonEncoder.withIndent('  ')
            .convert(request.toJson())}");

    try {
      final apiResponse = await repo.login(request);
      debugPrint("[_login] Received API response: status=${apiResponse
          .status}, message='${apiResponse.message}'");

      if (apiResponse.status) {
        final loginResponse = apiResponse.data as LoginResponse;
        debugPrint("[_login] LoginResponse received: isMulti=${loginResponse
            .isMulti}");

        if (loginResponse.isMulti) {
          debugPrint(
              "[_login] Multiple accounts found, emitting AuthMultipleAccountsFound");
          // save isMultiple as true here
          await repo.saveIsMultipleAccounts(true);
          emit(
            AuthMultipleAccountsFound(
              accounts: loginResponse.accountList,
              username: event.username,
              password: event.password,
              deviceName: event.deviceName,
              deviceType: event.deviceType,
              deviceUniqueId: event.deviceUniqueId,
              deviceToken: event.deviceToken,
            ),
          );
          return;
        }

        final user = loginResponse.userInfo!;
        debugPrint(
            "[_login] Single account found, saving user with deviceUniqueId: ${event
                .deviceUniqueId}");
        await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);
        await repo.saveLastLoginCredentials(
          username: event.username,
          password: event.password,
        );


        debugPrint(
            "[_login] User saved successfully, emitting AuthAuthenticated");
        final isMultipleAccounts = await repo.getSavedIsMultipleAccounts();

        emit(AuthAuthenticated(
          user: user,
          isMultipleAccounts: isMultipleAccounts,
        ));

      } else {
        if (apiResponse.message == "Already Logged In on another device") {
          debugPrint(
              "[_login] User already logged in on another device ${apiResponse
                  .message}");
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
          return;
        } else {
          debugPrint(
              "[_login] Login failed with message: ${apiResponse.message}");
          emit(AuthError(apiResponse.message));
        }
      }
    } catch (error) {
      debugPrint("[_login] Exception caught during login: ${error.toString()}");
      emit(AuthError(error.toString()));
    }
  }

  void _onAccountSelected(
      AccountSelected event,
      Emitter<AuthState> emit,
      ) {
    if (state is! AuthMultipleAccountsFound) return;

    final current = state as AuthMultipleAccountsFound;

    // Auto-login with selected account
    add(
      LoginRequested(
        username: current.username,
        password: current.password,
        selectedUserId: event.selectedAccount.userId,
        deviceName: current.deviceName,
        deviceType: current.deviceType,
        deviceUniqueId: current.deviceUniqueId,
        deviceToken: current.deviceToken,
        isForce: event.isForce,
        isSwitch: event.isSwitch,
      ),
    );
  }

  Future<void> _sessionCheck(
      SessionCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading("Checking session..."));

    try {
      final isValid = await repo.isSessionValid();

      if (isValid) {
        final user = await repo.getSavedUser();
        final isMultipleAccounts = await repo.getSavedIsMultipleAccounts();

        if (user != null) {
          emit(AuthAuthenticated(
            user: user,
            isMultipleAccounts: isMultipleAccounts,
          ));
        } else {
          emit(AuthSessionExpired("Not a valid session. Please login again."));
        }
      } else {
        emit(AuthSessionExpired("Session expired. Please login again."));
      }
    } catch (e) {
      // Don't log out on unexpected errors — show error instead
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _requestOtp(RequestOtpEvent event,
      Emitter<AuthState> emit) async {
    try {
      debugPrint("[_requestOtp] Requesting OTP for email: ${event.email}");

      final apiResponse = await repo.requestOtp(event.email);

      if (apiResponse.status) {
        debugPrint("[_requestOtp] OTP sent successfully");
        emit(OtpSentSuccess("OTP sent successfully"));
      } else {
        emit(OtpError("Failed to send OTP:"));
      }
    } catch (error) {
      debugPrint("[_requestOtp] Exception: ${error.toString()}");
      emit(OtpError(error.toString()));
    }
  }

  Future<void> _verifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    try {
      debugPrint("[_verifyOtp] Verifying OTP for email: ${event
          .email} with OTP: ${event.otp}");
      emit(AuthLoading("Verifying OTP..."));

      final apiResponse = await repo.verifyOtp(event.email, event.otp);

      if (apiResponse.status) {
        debugPrint(
            "[_verifyOtp] OTP verified successfully, proceeding with force login");
        emit(OtpVerifiedSuccess(apiResponse.message));

        // Now perform force login
        add(LoginRequested(
          username: event.username,
          password: event.password,
          deviceName: event.deviceName,
          deviceType: event.deviceType,
          deviceUniqueId: event.deviceUniqueId,
          deviceToken: event.deviceToken,
          isForce: true,
          isSwitch: false,
          selectedUserId: event.selectedUserId,
        ));
      } else {
        debugPrint(
            "[_verifyOtp] OTP verification failed: ${apiResponse.message}");
        emit(OtpError(apiResponse.message));
      }
    } catch (error) {
      debugPrint("[_verifyOtp] Exception: ${error.toString()}");
      emit(OtpError(error.toString()));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Logging out..."));

    await repo.logout(sessionId: event.sessionId);

    await repo.saveIsMultipleAccounts(false);

    emit(AuthSessionExpired("Session Expired...Log out Successfully."));

  }

  FutureOr<void> _resetAuthState(ResetAuthState event,
      Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}