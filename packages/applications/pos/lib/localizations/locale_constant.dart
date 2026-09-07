// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

const String prefSelectedLanguageCode = "SelectedLanguageCode";

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefSelectedLanguageCode, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(prefSelectedLanguageCode) ?? "th";
  return _locale(languageCode);
}

Locale _locale(String? languageCode) {
  return languageCode != null && languageCode.isNotEmpty
      ? Locale(languageCode, '')
      : const Locale('en', '');
}

Future<Locale> changeLanguage(
    BuildContext context, String selectedLanguageCode) async {
  return setLocale(selectedLanguageCode);
}
