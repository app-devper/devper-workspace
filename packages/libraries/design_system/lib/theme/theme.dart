// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/spacing.dart';

class CustomTheme {
  static ThemeData get mainTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: CustomColor.primary,
        primaryColorDark: Colors.cyan[600],
        // Roboto has no Thai glyphs, so Thai text fell back to whatever each
        // platform picked. Sarabun covers both scripts; Roboto stays behind it.
        fontFamily: 'Sarabun',
        fontFamilyFallback: const ['Roboto'],
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColor.primary,
          brightness: Brightness.light,
          error: CustomColor.error,
        ),
        scaffoldBackgroundColor: CustomColor.backgroundBase,
        buttonTheme: const ButtonThemeData(
          alignedDropdown: true,
          padding: EdgeInsets.symmetric(horizontal: 0),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: CustomColor.white,
          foregroundColor: CustomColor.fontBlack,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          displayMedium: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          displaySmall: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          headlineMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: CustomColor.fontBlack),
          titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: CustomColor.fontBlack),
          titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: CustomColor.fontBlack),
          bodyLarge: TextStyle(fontSize: 16.0, color: CustomColor.hintColor),
          bodyMedium: TextStyle(fontSize: 16.0, color: CustomColor.fontBlack),
          bodySmall: TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          labelLarge: TextStyle(color: CustomColor.white, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 16),
          labelMedium: TextStyle(color: CustomColor.fontBlack, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 14),
          labelSmall: TextStyle(color: CustomColor.hintColor, fontFamily: 'Sarabun', fontWeight: FontWeight.w500, fontSize: 12),
        ),
      );
}
