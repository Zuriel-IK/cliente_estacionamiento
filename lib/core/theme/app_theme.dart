import 'package:flutter/material.dart';

class AppColors {
  static const softBlush = Color(0xFFFFD9DA);
  static const blushRose = Color(0xFFEA638C);
  static const darkRaspberry = Color(0xFF89023E);
  static const jetBlack = Color(0xFF30343F);
  static const carbonBlack = Color(0xFF1B2021);

  static const rose50 = Color(0xFFFFF5F7);
  static const rose100 = Color(0xFFFFEEF2);
  static const rose150 = Color(0xFFFFE6EE);
  static const rose200 = Color(0xFFFFD6E2);
  static const rose400 = Color(0xFFF08CA8);

  static const neutralSoft = Color(0xFFF8F7F8);
  static const neutralWarm = Color(0xFFF4F1F3);
  static const whiteRose = Color(0xFFFFFCFD);

  static const successSoft = Color(0xFFDFF4E8);
  static const success = Color(0xFF2E9E5B);
  static const successDark = Color(0xFF1F6E3F);

  static const warningSoft = Color(0xFFFFF1D6);
  static const warning = Color(0xFFD99100);

  static const dangerSoft = Color(0xFFF9D9E4);
  static const danger = Color(0xFFB4235A);
}

class AppTheme {
  static final ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.blushRose,
    onPrimary: Colors.white,
    secondary: AppColors.darkRaspberry,
    onSecondary: Colors.white,
    tertiary: AppColors.softBlush,
    onTertiary: AppColors.jetBlack,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.whiteRose,
    onSurface: AppColors.jetBlack,
    outline: Color(0xFFE9C7D1),
    shadow: Color(0x14000000),
    scrim: Color(0x66000000),
    inverseSurface: AppColors.carbonBlack,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.softBlush,
  );

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppColors.rose50,
    cardColor: AppColors.whiteRose,
    dividerColor: const Color(0xFFEBCDD6),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.rose50,
      foregroundColor: AppColors.jetBlack,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blushRose,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}