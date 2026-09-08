// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/spacing.dart';

class CustomTheme {
  /// Kept as the light theme's name; hosts already reference it.
  static ThemeData get mainTheme => _build(Brightness.light, AppColors.light);

  static ThemeData get darkTheme => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) => ThemeData(
        brightness: brightness,
        extensions: [colors],
        primaryColor: CustomColor.primary,
        primaryColorDark: Colors.cyan[600],
        // Roboto has no Thai glyphs, so Thai text fell back to whatever each
        // platform picked. Sarabun covers both scripts; Roboto stays behind it.
        fontFamily: 'Sarabun',
        fontFamilyFallback: const ['Roboto'],
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColor.primary,
          brightness: brightness,
          error: CustomColor.error,
          surface: colors.surface,
        ),
        scaffoldBackgroundColor: colors.surface,
        buttonTheme: const ButtonThemeData(
          alignedDropdown: true,
          padding: EdgeInsets.symmetric(horizontal: 0),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colors.surfaceRaised,
          foregroundColor: colors.textPrimary,
          centerTitle: true,
        ),
        dividerTheme: DividerThemeData(color: colors.border),
        cardTheme: CardThemeData(color: colors.surfaceRaised),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          displayMedium: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          displaySmall: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          headlineMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: colors.textPrimary),
          titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: colors.textPrimary),
          titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: colors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16.0, color: colors.textHint),
          bodyMedium: TextStyle(fontSize: 16.0, color: colors.textPrimary),
          bodySmall: TextStyle(fontSize: 14.0, color: colors.textPrimary),
          labelLarge: TextStyle(color: CustomColor.white, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 16),
          labelMedium: TextStyle(color: colors.textPrimary, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 14),
          labelSmall: TextStyle(color: colors.textHint, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 12),
        ),
      );
}
