import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/device/device_info_service.dart';
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

  // AuthFlowHandler: this is the login screen, not home
  @override
  bool get isHomeContext => false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // buildAuthListener from the mixin wraps everything
    return Scaffold(
      body: buildAuthListener(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Card(
                          elevation: 0,
                          shadowColor: colorScheme.shadow.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Image.asset(
                                        'assets/images/app_logo.png'),
                                  ),
                                  const SizedBox(height: 24),

                                  Text(
                                    'Welcome Back',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Username
                                  TextFormField(
                                    controller: _usernameController,
                                    enabled: !isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Username or Email',
                                      hintText:
                                      'Enter your username or email',
                                      prefixIcon: const Icon(
                                          Icons.person_outline_rounded),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color:
                                            colorScheme.outlineVariant),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color:
                                            colorScheme.outlineVariant),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor:
                                      colorScheme.surfaceContainerLowest,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 18),
                                    ),
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Please enter your username or email'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: !isLoading,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () => setState(() =>
                                        _obscurePassword =
                                        !_obscurePassword),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color:
                                            colorScheme.outlineVariant),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color:
                                            colorScheme.outlineVariant),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor:
                                      colorScheme.surfaceContainerLowest,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 18),
                                    ),
                                    validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Please enter your password'
                                        : null,
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                      isLoading ? null : () {/* TODO */},
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed:
                                      isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor:
                                        colorScheme.onPrimary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        disabledBackgroundColor: colorScheme
                                            .onSurface
                                            .withOpacity(0.12),
                                      ),
                                      child: isLoading
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (state as AuthLoading)
                                                .message,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color>(
                                                colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  Column(
                                    children: [
                                      Text(
                                        '© 2026 Task Manager. All rights reserved.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Version 1.0.0',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}