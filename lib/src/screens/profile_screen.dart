import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signIn() async {
    try {
      await AuthService.signInWithGoogle();
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  /// 🔥 ЕДИНЫЙ СТИЛЬ КАРТОЧКИ (чтобы не дублировать код)
  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            /// 👤 АККАУНТ (у тебя уже был норм — просто перевели на общий стиль)
            _buildCard(
              Text(
                user != null
                    ? (user.email ?? '—')
                    : 'Аккаунт не подключён',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            const SizedBox(height: 16),

            /// 📊 СТАТИСТИКА (исправлено)
            _buildCard(
              Text(
                'Statistics placeholder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            const SizedBox(height: 16),

            /// ❤️ HEALTH CONNECT (исправлено)
            _buildCard(
              Text(
                'Health Connect status placeholder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            const SizedBox(height: 24),

            /// 🔐 КНОПКА ВХОДА / ВЫХОДА
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: user == null ? _signIn : _signOut,
              icon: Icon(user == null ? Icons.login : Icons.logout),
              label: Text(
                user == null ? 'Войти в аккаунт' : 'Выйти из аккаунта',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}