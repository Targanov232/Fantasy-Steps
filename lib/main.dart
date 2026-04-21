import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'src/data/step_storage.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/main_navigation_screen.dart';
import 'src/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await StepStorage.init();
  runApp(const FantasyStepApp());
}

class FantasyStepApp extends StatelessWidget {
  const FantasyStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Steps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Пока проверяем состояние Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;

        // 2. Если пользователь не вошел — на экран логина
        if (user == null) {
          return const LoginScreen();
        }

        // 3. Если вошел — СРАЗУ на главный экран.
        // Всю логику синхронизации (CloudStorage и Health Connect)
        // мы переносим в initState самого HomeScreen или MainNavigationScreen,
        // чтобы не блокировать вход в приложение.
        return const MainNavigatorScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/parchment_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2F6F3E),
            ),
          ),
        ],
      ),
    );
  }
}