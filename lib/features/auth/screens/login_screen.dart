import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/device/device_info_service.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();

    context.read<AuthBloc>().add(
      LoginRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        deviceUniqueId: deviceInfo.deviceUniqueId,
        deviceToken: deviceInfo.deviceToken,
        isForce: false,
        isSwitch: false,
      ),
    );
  }

  void _showMultiAccountDialog(List<UserModel> accounts) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Select Account"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: accounts.length,
            itemBuilder: (_, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.userName),
                subtitle: Text(account.userEmail),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(SelectAccount(account));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAlreadyLoggedInDialog(AuthAlreadyLoggedIn state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Already Logged In"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Would you like to verify and force login?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Request OTP
              context.read<AuthBloc>().add(
                RequestOtp(
                  username: state.username,
                  password: state.password,
                  deviceName: state.deviceName,
                  deviceType: state.deviceType,
                  deviceUniqueId: state.deviceUniqueId,
                  deviceToken: state.deviceToken,
                ),
              );
            },
            child: const Text("Get OTP"),
          ),
        ],
      ),
    );
  }

  void _showOtpVerificationDialog(AuthOtpSent state) {
    _otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, newState) {
          if (newState is AuthAuthenticated) {
            // Close dialog on successful authentication
            Navigator.pop(dialogContext);
          } else if (newState is AuthError) {
            // Show error but keep dialog open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(newState.message)),
            );
          }
        },
        builder: (context, currentState) {
          final isVerifying = currentState is AuthLoading;

          return AlertDialog(
            title: const Text("Verify OTP"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Enter the OTP sent to your registered email/phone:",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: "OTP",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                ),
                if (isVerifying)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isVerifying
                    ? null
                    : () {
                  final otp = _otpController.text.trim();
                  if (otp.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter OTP"),
                      ),
                    );
                    return;
                  }

                  // Verify OTP and force login
                  context.read<AuthBloc>().add(
                    VerifyOtpAndForceLogin(
                      otp: otp,
                      username: state.username,
                      password: state.password,
                      deviceName: state.deviceName,
                      deviceType: state.deviceType,
                      deviceUniqueId: state.deviceUniqueId,
                      deviceToken: state.deviceToken,
                    ),
                  );
                },
                child: isVerifying
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("Verify & Login"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AuthHasMultiAccount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMultiAccountDialog(state.accounts);
            });
          }

          if (state is AuthAlreadyLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAlreadyLoggedInDialog(state);
            });
          }

          if (state is AuthOtpSent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showOtpVerificationDialog(state);
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username / Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(width: 12),
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : const Text("Login"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}