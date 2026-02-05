import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/auth_request.dart';
import 'package:task_manager/features/auth/models/login_response.dart';
import 'package:task_manager/features/auth/repository/auth_repository.dart';

import '../models/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<SessionCheckRequested>(_sessionCheck);
    on<AccountSelected>(_onAccountSelected);
    on<LogoutRequested>(_logout);

  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Checking account..."));

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
      "AuthRequest:\n${const JsonEncoder.withIndent('  ').convert(request.toJson())}",
    );

    try {
      final apiResponse = await repo.login(request);

      // Api status is true then only check for multiple accounts and logic with single or multiple account
      if (apiResponse.status) {
        final loginResponse = apiResponse.data as LoginResponse;

        if (loginResponse.isMulti) {
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
        await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);

        emit(AuthAuthenticated(user));

      } else {
        if (apiResponse.message == "Already Logged In on another device") {
          // already login in another device
          return;
        } else {
          emit(AuthError(apiResponse.message));
        }
      }
    } catch (error) {
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
        isForce: false,
        isSwitch: true,
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

        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthSessionExpired("Not a valid session. Please login again."));
        }
      } else {
        emit(AuthSessionExpired("Session expired. Please login again."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Logging out..."));

    await repo.logout(sessionId: event.sessionId);

    emit(AuthSessionExpired("Session Expired...Log out Successfully."));

  }
}