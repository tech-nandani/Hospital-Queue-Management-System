import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.mainText,
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      outline: AppColors.border,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.mainText),
      displayMedium: TextStyle(color: AppColors.mainText),
      displaySmall: TextStyle(color: AppColors.mainText),
      headlineLarge: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.mainText),
      bodyMedium: TextStyle(color: AppColors.mainText),
      bodySmall: TextStyle(color: AppColors.secondaryText),
      labelLarge: TextStyle(color: AppColors.mainText, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: AppColors.secondaryText),
      labelSmall: TextStyle(color: AppColors.secondaryText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.mainText,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.mainText),
      titleTextStyle: TextStyle(
        color: AppColors.mainText,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: AppColors.mainText,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.mainText,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 48),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: AppColors.secondaryText,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
      dataTextStyle: TextStyle(
        color: AppColors.mainText,
        fontSize: 13,
      ),
    ),
  );
}