import 'package:flutter/material.dart';
import '../model/machine.dart';

class AppColors {
  static const ink = Color(0xFF16202E);
  static const inkSoft = Color(0xFF1F3A56);
  static const paper = Color(0xFFF1F4F7);
  static const card = Colors.white;
  static const line = Color(0xFFDDE3EA);
  static const steel = Color(0xFF5B6B7F);
  static const primary = Color(0xFF0E7C86);
  static const signal = Color(0xFF35C2CF);
  static const ok = Color(0xFF1E9E6A);
  static const warn = Color(0xFFE8A317);
  static const danger = Color(0xFFD6453D);

  static Color of(RiskLevel l) {
    if (l == RiskLevel.critical) return danger;
    if (l == RiskLevel.warning) return warn;
    return ok;
  }
}

class AppTheme {
  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.primary, surface: AppColors.card);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(AppColors.line),
        enabledBorder: _border(AppColors.line),
        focusedBorder: _border(AppColors.primary, 2),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, 2),
        labelStyle: const TextStyle(color: AppColors.steel),
        prefixIconColor: AppColors.steel,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
