import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationSheet extends StatefulWidget {
  final String email;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;
  final int? selectedUserId;



  const OtpVerificationSheet({
    super.key,
    required this.email,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    required this.isForce,
    required this.isSwitch,
    this.selectedUserId,
  });

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Automatically request OTP when sheet opens
    _requestOtp();
  }

  void _requestOtp() {
    setState(() => _isResending = true);
    context.read<AuthBloc>().add(RequestOtpEvent(email: widget.email));
  }

  void _verifyOtp() {
    if (_otpController.text.length == 4) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          email: widget.email,
          otp: _otpController.text,
          username: widget.username,
          password: widget.password,
          deviceName: widget.deviceName,
          deviceType: widget.deviceType,
          deviceUniqueId: widget.deviceUniqueId,
          deviceToken: widget.deviceToken,
          isForce: widget.isForce,
          isSwitch: widget.isSwitch,
          selectedUserId: widget.selectedUserId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          setState(() {
            _isOtpSent = true;
            _isResending = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is OtpError) {
          setState(() => _isResending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is OtpVerifiedSuccess) {
          debugPrint("[OtpVerificationSheet] OTP verified successfully");
          // Navigator.of(context).pop();

        }

        if (state is AuthAuthenticated) {
          debugPrint("[OtpVerificationSheet] AuthAuthenticated - navigating to home");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (route) => false);
        }

      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Verify Your Identity",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "We've sent a 4-digit code to\n${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input - Changed to 4 digits
              PinCodeTextField(
                appContext: context,
                length: 4, // Changed from 6 to 4
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 56, // Increased width since only 4 fields
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey.shade50,
                  selectedFillColor: Colors.white,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: Theme.of(context).primaryColor,
                ),
                enableActiveFill: true,
                onCompleted: (code) => _verifyOtp(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _requestOtp,
                    child: _isResending
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text("Resend"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isVerifying = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isVerifying
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}