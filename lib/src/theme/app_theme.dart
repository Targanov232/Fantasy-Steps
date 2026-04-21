import 'package:flutter/material.dart';

/// Base theme values. Can be replaced with textures later.
class AppColors {
  AppColors._();

  ///цвет игрока на карте
  static const Color mapPlayer = Colors.white;

  /// основная тема
  static const Color parchment = Color(0xFF17212B);

  /// карточки
  static const Color card = Color(0xFF1F2A36);

  /// акцент
  static const Color green = Color(0xFF2F6F3E);

  /// дополнительно
  static const Color gold = Color(0xFFC9A34A);

  /// текст
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
}

class AppTheme {
  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: AppColors.parchment,

    colorScheme: const ColorScheme.dark(
      background: AppColors.parchment,
      surface: AppColors.card,
      primary: AppColors.green,
      secondary: AppColors.gold,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),

      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),

      titleMedium: TextStyle(
        color: AppColors.textPrimary,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}