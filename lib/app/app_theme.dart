import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF00B2A9);
  static const primaryDark = Color(0xFF00736D);
  static const accent = Color(0xFFFFC857);
  static const backgroundDark = Color(0xFF0E1113);
  static const surfaceDark = Color(0xFF1B1F22);
  static const backgroundLight = Color(0xFFF6F9FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const error = Color(0xFFEF5350);
  static const success = Color(0xFF4CAF50);
}

ThemeData _baseDark() => ThemeData.dark(useMaterial3: true);
ThemeData _baseLight() => ThemeData.light(useMaterial3: true);

ThemeData buildDarkTheme() {
  final base = _baseDark();
  return _applyShared(base, dark: true);
}

ThemeData buildLightTheme() {
  final base = _baseLight();
  return _applyShared(base, dark: false);
}

ThemeData _applyShared(ThemeData base, {required bool dark}) {
  final isDark = dark;
  final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  final surf = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  final onPrimary = Colors.white;
  final onSecondary = isDark ? Colors.black : Colors.black;
  final onSurf = isDark ? Colors.white : Colors.black;
  final scheme = base.colorScheme.copyWith(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: surf,
    error: AppColors.error,
    onPrimary: onPrimary,
    onSecondary: onSecondary,
    onSurface: onSurf,
    onError: Colors.white,
    brightness: isDark ? Brightness.dark : Brightness.light,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: surf,
      foregroundColor: onSurf,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surf,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: onSurf.withValues(alpha: 0.5)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surf,
      contentTextStyle: TextStyle(color: onSurf),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: AppColors.primary,
      thumbColor: AppColors.accent,
      inactiveTrackColor: Color.lerp(
        AppColors.primary,
        Colors.transparent,
        0.3,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}
