import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/admin_session.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await AdminSession.login(_userController.text, _passController.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.admin_panel_settings, size: 56, color: AppColors.dark),
                const SizedBox(height: 12),
                const Text(
                  'GoCab Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to manage bookings',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Default: admin / admin123\n(change this in lib/services/admin_session.dart)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
