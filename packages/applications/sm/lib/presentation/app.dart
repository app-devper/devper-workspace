// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:common/core/theme/theme.dart';
import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:sm/presentation/constants.dart';
import 'package:sm/presentation/router.dart';

class DevperSm extends StatefulWidget {
  final AppConfig config;

  const DevperSm({super.key, required this.config});

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<DevperSm> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevperSM',
      theme: CustomTheme.mainTheme,
      onGenerateRoute: RouterApp.generateRoute,
      initialRoute: ROOT_ROUTE,
      locale: _locale,
      supportedLocales: const [
        Locale('th', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: [
        CommonLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode && supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
