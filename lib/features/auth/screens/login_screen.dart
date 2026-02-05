import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/device/device_info_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../dialogs/multi_account_dialog.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

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

  void showMultiAccountSheet(
      BuildContext context,
      List<UserModel> accounts,
      Function(UserModel) onSelected,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return MultiAccountSheet(
          accounts: accounts,
          onAccountSelected: onSelected,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final theme = Theme.of(context);


    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          if (state is AuthMultipleAccountsFound) {
            showMultiAccountSheet(
              context,
              state.accounts,
                  (account) {
                  Navigator.of(context).pushReplacementNamed('/home');
                context.read<AuthBloc>().add(
                  AccountSelected(
                    selectedAccount: account,
                  ),
                );
              },
            );
          }


        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Card(
                          elevation: 0,
                          shadowColor: Colors.black.withOpacity(0.3),
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
                                  // Logo or Icon
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Image.asset(
                                      'assets/images/app_logo.png',
                                      width: 140,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Title
                                  Text(
                                    "Welcome Back",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sign in to continue",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Username Field
                                  TextFormField(
                                    controller: _usernameController,
                                    enabled: !isLoading,
                                    decoration: InputDecoration(
                                      labelText: "Username or Email",
                                      hintText: "Enter your username or email",
                                      prefixIcon: const Icon(
                                          Icons.person_outline_rounded),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF667eea),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade50,
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return 'Please enter your username or email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: !isLoading,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      hintText: "Enter your password",
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
                                            : () {
                                          setState(() {
                                            _obscurePassword =
                                            !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade50,
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }

                                      return null;
                                    },
                                  ),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: isLoading ? null : () {
                                        // Handle forgot password
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16),
                                        ),
                                        disabledBackgroundColor: Colors.grey
                                            .shade300,
                                      ),
                                      child: isLoading
                                          ? Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Text(
                                            state.message,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : const Text(
                                        "Sign In",
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
                                        "© 2025 Task Manager. All rights reserved.",
                                        textAlign: TextAlign.center,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Version 1.0.0",
                                        textAlign: TextAlign.center,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  )
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