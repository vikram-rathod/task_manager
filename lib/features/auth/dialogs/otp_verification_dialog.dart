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
    required this.isSwitch,
    this.selectedUserId,
  });

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  // ⚠️ Do NOT pass this to PinCodeTextField — the package disposes it
  // internally when the widget unmounts, causing a double-dispose crash.
  String _otpValue = '';
  bool _isResending = false;

  // Inline feedback — null means no message shown
  String? _errorMessage;
  String? _successMessage;

  // Key to force PinCodeTextField to clear on error
  Key _pinKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _requestOtp();
  }

  void _requestOtp() {
    if (!mounted) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });
    context.read<AuthBloc>().add(RequestOtpEvent(email: widget.email));
  }

  void _verifyOtp() {
    if (_otpValue.length != 4) return;
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        email: widget.email,
        otp: _otpValue,
        username: widget.username,
        password: widget.password,
        deviceName: widget.deviceName,
        deviceType: widget.deviceType,
        deviceUniqueId: widget.deviceUniqueId,
        deviceToken: widget.deviceToken,
        isSwitch: widget.isSwitch,
        selectedUserId: widget.selectedUserId,
      ),
    );
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _successMessage = null;
      // Reset the pin field so user can re-enter cleanly
      _otpValue = '';
      _pinKey = UniqueKey();
    });
  }

  void _setSuccess(String message) {
    if (!mounted) return;
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is OtpSentSuccess) {
          setState(() => _isResending = false);
          _setSuccess(state.message.isNotEmpty ? state.message : 'OTP sent to ${widget.email}');
        }

        if (state is OtpError) {
          setState(() => _isResending = false);
          _setError(state.message.isNotEmpty
              ? state.message
              : 'Invalid OTP. Please check and try again.');
        }

        if (state is OtpVerifiedSuccess) {
          _setSuccess('OTP verified! Logging in…');
          // Do NOT pop — AuthFlowHandler navigates via pushNamedAndRemoveUntil
          // when AuthAuthenticated fires, dismissing all sheets automatically.
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar + close button ──────────────────────────────────
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 18, color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Icon ──────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_outlined,
                    size: 40, color: scheme.primary),
              ),
              const SizedBox(height: 16),

              Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We've sent a 4-digit code to\n${widget.email}",
                textAlign: TextAlign.center,
                style:
                TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ── PIN input ─────────────────────────────────────────────────
              PinCodeTextField(
                key: _pinKey, // rebuilt on error to clear the field
                appContext: context,
                length: 4,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 54,
                  fieldWidth: 54,
                  activeFillColor: scheme.surface,
                  inactiveFillColor: scheme.surfaceVariant.withOpacity(0.4),
                  selectedFillColor: scheme.surface,
                  // Red border when there's an error
                  activeColor: _errorMessage != null
                      ? scheme.error
                      : scheme.primary,
                  inactiveColor: _errorMessage != null
                      ? scheme.error.withOpacity(0.4)
                      : scheme.outline.withOpacity(0.5),
                  selectedColor: _errorMessage != null
                      ? scheme.error
                      : scheme.primary,
                ),
                enableActiveFill: true,
                onChanged: (value) {
                  _otpValue = value;
                  // Clear error as user starts re-typing
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                onCompleted: (_) => _verifyOtp(),
              ),

              // ── Inline error message ──────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _errorMessage != null
                    ? _FeedbackBanner(
                  key: ValueKey(_errorMessage),
                  message: _errorMessage!,
                  isError: true,
                  scheme: scheme,
                )
                    : _successMessage != null
                    ? _FeedbackBanner(
                  key: ValueKey(_successMessage),
                  message: _successMessage!,
                  isError: false,
                  scheme: scheme,
                )
                    : const SizedBox.shrink(key: ValueKey('none')),
              ),

              const SizedBox(height: 12),

              // ── Resend ────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _requestOtp,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _isResending
                        ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                        : Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Verify button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading =
                        state is AuthLoading || state is OtpVerifiedSuccess;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Text(
                        'Verify OTP',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline banner shown directly beneath the PIN field.
class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final ColorScheme scheme;

  const _FeedbackBanner({
    super.key,
    required this.message,
    required this.isError,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? scheme.error : Colors.green.shade600;
    final bgColor = isError
        ? scheme.error.withOpacity(0.08)
        : Colors.green.withOpacity(0.08);
    final icon =
    isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}