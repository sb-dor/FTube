// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

/// Brand colors.
abstract final class AppColors {
  static const Color accent = Color(0xFFE53935);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F2FA);
  static const Color badge = Color(0xCC000000);
  static const Color inactive = Color(0x4D000000);
}

/// App theme.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      surface: AppColors.background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accent),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
