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

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();

    context.read<AuthBloc>().add(
      LoginRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        deviceUniqueId: deviceInfo.deviceUniqueId,
        deviceToken: deviceInfo.deviceToken,
      ),
    );
  }

  void _showMultiAccountDialog(List<UserModel> accounts) {
    showDialog(
      context: context,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _isLoading = state is AuthLoading;

          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AuthHasMultiAccount) {
            _showMultiAccountDialog(state.accounts);
          }

          // When AuthAuthenticated occurs, AuthWrapper automatically shows Home
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
