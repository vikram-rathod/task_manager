import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/bloc/auth_event.dart';
import 'package:task_manager/features/auth/bloc/auth_state.dart';
import 'package:task_manager/features/auth/models/auth_request.dart';
import 'package:task_manager/features/auth/models/login_response.dart';
import 'package:task_manager/features/auth/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_login);
    on<SelectAccount>(_selectAccount);
    on<RequestOtp>(_requestOtp);
    on<VerifyOtpAndForceLogin>(_verifyOtpAndForceLogin);
    on<LogoutRequested>(_logout);
  }


  /// APP STARTED - Check for existing session
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Initializing..."));

    try {
      // Validate session first
      final isValid = await repo.isSessionValid();

      if (!isValid) {
        await repo.logout();
        emit(AuthInitial());
        return;
      }

      final savedUser = await repo.getSavedUser();

      if (savedUser != null) {
        emit(AuthAuthenticated(savedUser));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      await repo.logout();
      emit(AuthInitial());
    }
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Checking account..."));

    final request = AuthRequest(
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
    try {
      final apiResponse = await repo.login(request);

      // Api status is true then only check for multiple accounts and logic with single or multiple account
      if (apiResponse.status) {
        final loginResponse = apiResponse.data as LoginResponse;

        if (loginResponse.isMulti) {
          emit(
            AuthHasMultiAccount(
              message: "Multiple accounts found",
              accounts: loginResponse.accountList,
            ),
          );

          return;
        }

        final user = loginResponse.userInfo!;
        await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);

        emit(AuthAuthenticated(user));

      } else {
        if (apiResponse.message == "Already Logged In on another device") {
          emit(AuthAlreadyLoggedInAnotherDevice(
            message: apiResponse.message,
            username: event.username,
            password: event.password,
            deviceName: event.deviceName,
            deviceType: event.deviceType,
            deviceUniqueId: event.deviceUniqueId,
            deviceToken: event.deviceToken,
          ));
          return;
        } else {
          emit(AuthError(apiResponse.message));
        }
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _requestOtp(RequestOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading("Sending OTP..."));
    try {
      // Pass username as email parameter
      final response = await repo.requestOtp(event.username);

      if (response.status) {
        emit(AuthOtpSent(
          message: response.message.isNotEmpty
              ? response.message
              : "OTP sent successfully to your registered email",
          username: event.username,
          password: event.password,
          deviceName: event.deviceName,
          deviceType: event.deviceType,
          deviceUniqueId: event.deviceUniqueId,
          deviceToken: event.deviceToken,

        ));
      } else {
        emit(AuthError(response.message.isNotEmpty
            ? response.message
            : "Failed to send OTP"));
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _verifyOtpAndForceLogin(
      VerifyOtpAndForceLogin event,
      Emitter<AuthState> emit,
      ) async {

    emit(AuthLoading("Verifying OTP..."));

    try {
      final verifyResponse = await repo.verifyOtp(event.username, event.otp);

      if (verifyResponse.status) {

        emit(AuthLoading("Forcing login..."));

        // Now perform force login
        final request = AuthRequest(
          username: event.username,
          password: event.password,
          deviceName: event.deviceName,
          deviceType: event.deviceType,
          deviceUniqueId: event.deviceUniqueId,
          deviceToken: event.deviceToken,
          isForce: true, // Force login = true
          isSwitch: false,
          appType: "2",
        );

        final apiResponse = await repo.login(request);
        final loginResponse = apiResponse.data as LoginResponse;

        if (apiResponse.status) {

          if (loginResponse.isMulti) {
            emit(
              AuthHasMultiAccount(
                message: "Multiple accounts found",
                accounts: loginResponse.accountList,
              ),
            );
            return;
          }
          final user = loginResponse.userInfo!;
          await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);

          emit(AuthAuthenticated(user));

        } else {
          emit(AuthError(apiResponse.message));
        }
      } else {
        emit(AuthError(verifyResponse.message.isNotEmpty
            ? verifyResponse.message
            : "Invalid OTP"));
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _selectAccount(
      SelectAccount event,
      Emitter<AuthState> emit,
      ) async {

    emit(AuthLoading("Signing into selected account..."));
    await repo.saveUser(event.account);
    emit(AuthAuthenticated(event.account));

  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading("Logging out..."));

    await repo.logout();

    emit(AuthInitial());

  }
}