// Flutter imports:
import 'package:flutter/material.dart';

class CustomColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color fontBlack = Color(0xDE000000);
  static const Color primary = Color(0xFF245f97);
  static const Color textFieldBackground = Color(0x1E000000);
  static const Color hintColor = Color(0x99000000);
  static const Color statusBarColor = Color(0x1e000000);
}

class CustomTheme {
  static ThemeData mainTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: CustomColor.primary,
    primaryColorDark: Colors.cyan[600],
    fontFamily: 'Roboto',
    useMaterial3: false,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: CustomColor.fontBlack,
      ),
      titleLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: CustomColor.fontBlack,
      ),
      bodyMedium: TextStyle(
        fontSize: 16.0,
        color: CustomColor.fontBlack,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: CustomColor.hintColor,
      ),
      labelLarge: TextStyle(
        color: CustomColor.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      alignedDropdown: true,
      padding: EdgeInsets.symmetric(horizontal: 0),
    ),
  );
}
