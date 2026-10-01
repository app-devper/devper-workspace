// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/theme/radius.dart';

class CustomTheme {
  /// Kept as the light theme's name; hosts already reference it.
  static ThemeData get mainTheme => _build(Brightness.light, AppColors.light);

  static ThemeData get darkTheme => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) => ThemeData(
    brightness: brightness,
    extensions: [colors],
    primaryColor: colors.textPrimary,
    primaryColorDark: colors.textPrimary,
    // Roboto has no Thai glyphs, so Thai text fell back to whatever each
    // platform picked. Sarabun covers both scripts; Roboto stays behind it.
    fontFamily: 'Sarabun',
    fontFamilyFallback: const ['Roboto'],
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.textPrimary,
      brightness: brightness,
      error: CustomColor.error,
      surface: colors.surface,
      primary: colors.textPrimary,
      onPrimary: colors.surface,
      secondary: colors.textPrimary,
      onSecondary: colors.surface,
    ),
    scaffoldBackgroundColor: colors.surface,
    buttonTheme: const ButtonThemeData(
      alignedDropdown: true,
      padding: EdgeInsets.symmetric(horizontal: 0),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(
          AppSpacing.minTouchTarget,
          AppSpacing.minTouchTarget,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surfaceRaised,
      foregroundColor: colors.textPrimary,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: colors.border),
    cardTheme: CardThemeData(
      color: colors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceSunken,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.textSecondary),
      ),
      hintStyle: TextStyle(color: colors.textSecondary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.textPrimary,
        foregroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.textPrimary,
      foregroundColor: colors.surface,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 40.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16.0, color: colors.textHint),
      bodyMedium: TextStyle(fontSize: 16.0, color: colors.textPrimary),
      bodySmall: TextStyle(fontSize: 14.0, color: colors.textPrimary),
      labelLarge: TextStyle(
        color: colors.textPrimary,
        fontFamily: 'Sarabun',
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      labelMedium: TextStyle(
        color: colors.textPrimary,
        fontFamily: 'Sarabun',
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelSmall: TextStyle(
        color: colors.textHint,
        fontFamily: 'Sarabun',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
}
