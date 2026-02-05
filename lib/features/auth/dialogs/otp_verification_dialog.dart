import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationDialog extends StatefulWidget {

  const OtpVerificationDialog({
    super.key,
  });

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpVerificationDialog(),
    );
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, newState) {
        if (newState is AuthAuthenticated) {
          // Close dialog on successful authentication
          Navigator.pop(context);
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
              onPressed: isVerifying
                  ? null
                  : () {
                Navigator.pop(context);
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
    );
  }
}