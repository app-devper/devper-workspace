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
  static ThemeData mainTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: CustomColor.primary,
      primaryColorDark: Colors.cyan[600],
      fontFamily: 'Roboto',
      useMaterial3: false,
      textTheme: Theme.of(context).textTheme.apply(
            fontSizeDelta: 0.0,
          ),
      buttonTheme: const ButtonThemeData(
        alignedDropdown: true,
        padding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
