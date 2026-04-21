import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final user = await AuthService.signInWithGoogle();

      if (user == null) return;

      // _AuthGate автоматически переключит экран

    } catch (e) {

      setState(() {
        _error = 'Ошибка входа: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа: $e')),
        );
      }

    } finally {

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

    }
  }

  void _continueWithoutLogin() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigatorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(
                'Fantasy Steps',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Войдите через Google,\n'
                    'чтобы синхронизировать прогресс,\n'
                    'или продолжайте без входа.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _signIn,
                  icon: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.login),

                  label: Text(_loading ? 'Вход...' : 'Войти через Google'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _loading ? null : _continueWithoutLogin,
                child: const Text('Продолжить без входа'),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
}