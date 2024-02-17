// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';

// Project imports:
import 'language/language_en.dart';
import 'language/language_th.dart';
import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  final AppConfig config;

  AppLocalizationsDelegate({required this.config});

  @override
  bool isSupported(Locale locale) => ['en', 'th'].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale, config);

  static Future<Languages> _load(Locale locale, AppConfig config) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'th':
        return LanguageTh(config: config);
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
