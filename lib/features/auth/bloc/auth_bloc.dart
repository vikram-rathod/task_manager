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

  void _logDivider(String title) {
    print("\n======================================");
    print(" $title");
    print("======================================");
  }

  /// APP STARTED - Check for existing session
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    _logDivider("APP STARTED");

    emit(AuthLoading("Initializing..."));

    try {
      // Validate session first
      final isValid = await repo.isSessionValid();

      if (!isValid) {
        print("❌ Session invalid or expired");
        await repo.logout();
        emit(AuthInitial());
        return;
      }

      final savedUser = await repo.getSavedUser();

      if (savedUser != null) {
        print("✅ Session restored: ${savedUser.userName}");
        print("🏢 Company: ${savedUser.companyName}");
        print("🔑 Session ID: ${savedUser.loginSessionId}");
        emit(AuthAuthenticated(savedUser));
      } else {
        print("ℹ️ No active session");
        emit(AuthInitial());
      }
    } catch (e) {
      print("❌ Session restore failed: $e");
      await repo.logout();
      emit(AuthInitial());
    }

    _logDivider("SESSION CHECK COMPLETED");
  }

  Future<void> _login(LoginRequested event, Emitter<AuthState> emit) async {
    _logDivider("LOGIN REQUEST STARTED");

    print(" Username: ${event.username}");
    print("Device Name: ${event.deviceName}");
    print(" Device Type: ${event.deviceType}");
    print(" Device Unique ID: ${event.deviceUniqueId}");
    print(" Device Token: ${event.deviceToken}");

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
      print(" Calling Login API...");
      final apiResponse = await repo.login(request);
      final loginResponse = apiResponse.data as LoginResponse;

      print(" Login API Response received");

      // api status is true then only check for multiple accounts and logic with single or multiple account
      if (apiResponse.status) {
        print(" isMultiAccount: ${loginResponse.isMulti}");

        if (loginResponse.isMulti) {
          print(" Multiple accounts found: ${loginResponse.accountList.length}");
          for (var acc in loginResponse.accountList) {
            print("   • ${acc.userName} | ${acc.userEmail}");
          }

          emit(
            AuthHasMultiAccount(
              message: "Multiple accounts found",
              accounts: loginResponse.accountList,
            ),
          );

          return;
        }

        final user = loginResponse.userInfo!;
        print(" Single account login: ${user.userName}");
        print(" Company: ${user.companyName}");
        print(" Session ID: ${user.loginSessionId}");

        await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);

        print(" User saved to local storage");

        emit(AuthAuthenticated(user));

        _logDivider("LOGIN REQUEST COMPLETED");
      } else {
        if (apiResponse.message == "Already Logged In on another device") {
          print("⚠User already logged in on another device");
          emit(AuthAlreadyLoggedIn(
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
      print(" Login error: $error");
      _logDivider("LOGIN FAILED");
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _requestOtp(RequestOtp event, Emitter<AuthState> emit) async {
    _logDivider("OTP REQUEST STARTED");

    // The API expects email, so we use username (which can be email)
    print(" Email/Username: ${event.username}");

    emit(AuthLoading("Sending OTP..."));

    try {
      print(" Calling Request OTP API...");
      // Pass username as email parameter
      final response = await repo.requestOtp(event.username);

      if (response.status) {
        print(" OTP sent successfully");
        print(" Message: ${response.message}");

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

        _logDivider("OTP REQUEST COMPLETED");
      } else {
        print(" OTP request failed: ${response.message}");
        emit(AuthError(response.message.isNotEmpty
            ? response.message
            : "Failed to send OTP"));
      }
    } catch (error) {
      print(" OTP request error: $error");
      _logDivider("OTP REQUEST FAILED");
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _verifyOtpAndForceLogin(
      VerifyOtpAndForceLogin event,
      Emitter<AuthState> emit,
      ) async {
    _logDivider("OTP VERIFICATION & FORCE LOGIN STARTED");

    print(" Email/Username: ${event.username}");
    print(" OTP: ${event.otp}");

    emit(AuthLoading("Verifying OTP..."));

    try {
      print(" Calling Verify OTP API...");
      // Pass username as email parameter
      final verifyResponse = await repo.verifyOtp(event.username, event.otp);

      if (verifyResponse.status) {
        print(" OTP verified successfully");

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

        print(" Calling Login API with force=true...");
        final apiResponse = await repo.login(request);
        final loginResponse = apiResponse.data as LoginResponse;

        if (apiResponse.status) {
          print(" isMultiAccount: ${loginResponse.isMulti}");

          if (loginResponse.isMulti) {
            print("👥 Multiple accounts found: ${loginResponse.accountList.length}");
            for (var acc in loginResponse.accountList) {
              print("   • ${acc.userName} | ${acc.userEmail}");
            }

            emit(
              AuthHasMultiAccount(
                message: "Multiple accounts found",
                accounts: loginResponse.accountList,
              ),
            );

            return;
          }

          final user = loginResponse.userInfo!;
          print(" Force login successful: ${user.userName}");
          print(" Company: ${user.companyName}");
          print(" Session ID: ${user.loginSessionId}");

          await repo.saveUser(user, deviceUniqueId: event.deviceUniqueId);

          print(" User saved to local storage");

          emit(AuthAuthenticated(user));

          _logDivider("FORCE LOGIN COMPLETED");
        } else {
          print(" Force login failed: ${apiResponse.message}");
          emit(AuthError(apiResponse.message));
        }
      } else {
        print(" OTP verification failed: ${verifyResponse.message}");
        emit(AuthError(verifyResponse.message.isNotEmpty
            ? verifyResponse.message
            : "Invalid OTP"));
      }
    } catch (error) {
      print(" Verification error: $error");
      _logDivider("VERIFICATION FAILED");
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _selectAccount(
      SelectAccount event,
      Emitter<AuthState> emit,
      ) async {
    _logDivider("MULTI-ACCOUNT SELECTION");

    print(" Selected Account: ${event.account.userName}");
    print(" Email: ${event.account.userEmail}");
    print(" Company: ${event.account.companyName}");

    emit(AuthLoading("Signing into selected account..."));

    await repo.saveUser(event.account);

    print(" Selected account saved locally");
    print(" Session ID: ${event.account.loginSessionId}");

    emit(AuthAuthenticated(event.account));

    _logDivider("ACCOUNT SELECTION COMPLETED");
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    _logDivider("LOGOUT STARTED");

    emit(AuthLoading("Logging out..."));

    await repo.logout();

    print("🗑 Local storage cleared");
    print(" User logged out successfully");

    emit(AuthInitial());

    _logDivider("LOGOUT COMPLETED");
  }
}