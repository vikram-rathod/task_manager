import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/device/device_info_service.dart';
import '../../../reusables/wave_background.dart';
import '../auth_flow_handler.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, AuthFlowHandler {

  @override
  bool get isHomeContext => false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool  _obscurePassword    = true;

  late AnimationController _animationController;
  late Animation<double>   _fadeAnimation;
  late Animation<Offset>   _slideAnimation;

  static const Color _primaryGreen     = Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25), end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final deviceInfo = await DeviceInfoService.getDeviceInfo();
      if (!mounted) return;
      context.read<AuthBloc>().add(
        LoginRequested(
          username:       _usernameController.text.trim(),
          password:       _passwordController.text.trim(),
          deviceName:     deviceInfo.deviceName,
          deviceType:     deviceInfo.deviceType,
          deviceUniqueId: deviceInfo.deviceUniqueId,
          deviceToken:    deviceInfo.deviceToken,
          isForce:        false,
          isSwitch:       false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark         = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    // ── Theme-aware colours ───────────────────────────────────────────────────
    final Color scaffoldBg  = isDark ? const Color(0xFF0D110E) : const Color(0xFFF7F9F7);
    final Color cardBg      = isDark ? const Color(0xFF1A1F1B) : const Color(0xFFFFFFFF);
    final Color fieldBg     = isDark ? const Color(0xFF252A26) : const Color(0xFFF5F7F5);
    final Color fieldBorder = isDark ? const Color(0xFF3A403B) : const Color(0xFFDDE5DD);
    final Color textPrimary = isDark ? const Color(0xFFECECEC) : const Color(0xFF1A1A1A);
    final Color textMuted   = isDark ? const Color(0xFF8A9A8B) : const Color(0xFF7A8A7B);
    final Color logoBg      = isDark ? const Color(0xFF1E2E20) : const Color(0xFFE8F0E9);
    final Color green       = isDark ? const Color(0xFF40916C) : _primaryGreen;
    final Color btnGreen    = isDark ? const Color(0xFF40916C) : _primaryGreen;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: scaffoldBg,
      body: buildAuthListener(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return ProChatWaveBackground(
              primaryColor:       green,
              wavePosition:       isKeyboardOpen ? 0.88 : 0.72,
              primaryWaveAlpha:   0.28,
              secondaryWaveAlpha: 0.33,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ── Scrollable body ─────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Top spacing
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    height: isKeyboardOpen ? 20 : 52,
                                  ),

                                  // ── Logo circle ──────────────────────────
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: logoBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Image.asset(
                                            'assets/images/app_logo.png'),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── App name: "Task" normal + "Manager" green ─
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Task '),
                                        TextSpan(
                                          text: 'Manager',
                                          style: TextStyle(color: green),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    'Sign in to continue your Task Manager experience',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textMuted,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Card ─────────────────────────────────
                                  Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 500),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(isDark ? 0.3 : 0.07),
                                          blurRadius: 24,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 24, 20, 20),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                          children: [
                                            // ── Email field ──────────────
                                            _buildInputField(
                                              controller: _usernameController,
                                              enabled: !isLoading,
                                              hint: 'Username',
                                              label: "Username",
                                              prefixIcon:
                                              Icons.email_rounded,
                                              keyboardType:
                                              TextInputType.emailAddress,
                                              fieldBg: fieldBg,
                                              fieldBorder: fieldBorder,
                                              textColor: textPrimary,
                                              hintColor: textMuted,
                                              iconColor: textPrimary,
                                              isDark: isDark,
                                              validator: (v) =>
                                              (v == null ||
                                                  v.trim().isEmpty)
                                                  ? 'Please enter your Username'
                                                  : null,
                                            ),

                                            const SizedBox(height: 24),

                                            // ── Password field ───────────
                                            _buildInputField(
                                              controller: _passwordController,
                                              enabled: !isLoading,
                                              hint: 'Password',
                                              label: "Password",
                                              prefixIcon:
                                              Icons.lock,
                                              obscureText: _obscurePassword,
                                              fieldBg: fieldBg,
                                              fieldBorder: fieldBorder,
                                              textColor: textPrimary,
                                              hintColor: textMuted,
                                              iconColor: textPrimary,
                                              isDark: isDark,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                      .visibility_outlined
                                                      : Icons
                                                      .visibility_off_outlined,
                                                  color: textMuted,
                                                  size: 20,
                                                ),
                                                onPressed: isLoading
                                                    ? null
                                                    : () => setState(() =>
                                                _obscurePassword =
                                                !_obscurePassword),
                                              ),
                                              validator: (v) =>
                                              (v == null || v.isEmpty)
                                                  ? 'Please enter your password'
                                                  : null,
                                            ),

                                            const SizedBox(height: 32),

                                            // ── Sign In button ───────────
                                            SizedBox(
                                              height: 52,
                                              child: ElevatedButton.icon(
                                                onPressed: isLoading
                                                    ? null
                                                    : _login,
                                                icon: isLoading
                                                    ? SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white
                                                            .withOpacity(
                                                            0.9)),
                                                  ),
                                                )
                                                    : const Icon(
                                                  Icons.login_rounded,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                label: isLoading
                                                    ? Text(
                                                  (state as AuthLoading)
                                                      .message,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                )
                                                    : const Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: Colors.white,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                style:
                                                ElevatedButton.styleFrom(
                                                  backgroundColor: btnGreen,
                                                  elevation: 0,
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                  ),
                                                  disabledBackgroundColor:
                                                  btnGreen.withOpacity(0.5),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // ── Forgot Password ──────────
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton(
                                                onPressed: isLoading
                                                    ? null
                                                    : () {/* TODO */},
                                                style: TextButton.styleFrom(
                                                  foregroundColor: green,
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                                ),
                                                child: const Text(
                                                  'Forgot Password?',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Footer — always visible, hides when keyboard opens ──
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: isKeyboardOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Text(
                                '© 2026 Task Manager • v 1.2.10',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textMuted.withOpacity(0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds a field that matches the image:
  /// - Email: single hint line (no label)
  /// - Password: small "Password" label on top + "Enter your password" hint below
  Widget _buildInputField({
    required TextEditingController controller,
    required bool                  enabled,
    String?                        label,
    required String                hint,
    required IconData              prefixIcon,
    Widget?                        suffixIcon,
    bool                           obscureText = false,
    TextInputType?                 keyboardType,
    required Color                 fieldBg,
    required Color                 fieldBorder,
    required Color                 textColor,
    required Color                 hintColor,
    required Color                 iconColor,
    required bool                  isDark,
    String? Function(String?)?     validator,
  }) {
    final bool hasLabel = label != null;

    return TextFormField(
      controller:   controller,
      enabled:      enabled,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize:   15,
        color:      textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          fontSize:   14,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color:      hintColor,
          fontSize:   15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: iconColor, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: fieldBorder, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}