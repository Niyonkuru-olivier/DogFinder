import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5E60CE);
  static const secondary = Color(0xFF6930C3);
  static const accent = Color(0xFF48BFE3);

  static const lightBackground = Color(0xFFF5F7FA);
  static const darkBackground = Color(0xFF121218);
  static const darkSurface = Color(0xFF1E1E2C);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
    ),
    fontFamily: 'Roboto',
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
    ),
    fontFamily: 'Roboto',
  );
}
