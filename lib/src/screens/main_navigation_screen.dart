import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'world_selection_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';
import '../widgets/main_bottom_bar.dart';

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _currentIndex = 0;

  /// Single source of truth for worlds tab internal state.
  final GlobalKey<WorldSelectionScreenState> _worldKey = GlobalKey();

  late final List<Widget> _pages = [
    /// 0: Миры
    WorldSelectionScreen(key: _worldKey),

    /// 1: Награды
    const RewardsScreen(),

    /// 2: Профиль
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == 0) {
      // Always reset to world list when opening "Worlds".
      _worldKey.currentState?.resetToWorldList();
    }

    // Same-tab tap behavior (Instagram-like reset).
    if (_currentIndex == index) {
      if (index == 0) {
        _worldKey.currentState?.resetToWorldList();
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  /// Centralized back behavior:
  /// - non-worlds tab -> switch to worlds
  /// - worlds inside home -> back to worlds list
  /// - worlds list -> allow app exit
  bool _handleBack() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      _worldKey.currentState?.resetToWorldList();
      return false; // handled
    }

    final handledInside = _worldKey.currentState?.handleBack() ?? false;
    if (handledInside) {
      return false; // handled
    }

    return true; // allow exit
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final shouldExit = _handleBack();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: MainBottomBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}