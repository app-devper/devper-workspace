// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:pos/localizations/locale_constant.dart';
import 'package:pos/localizations/localizations_delegate.dart';
import 'package:pos/presentation/constants.dart';
import 'router.dart';
import 'theme.dart';

class DevperPos extends StatefulWidget {
  final AppConfig config;

  const DevperPos({super.key, required this.config});

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<DevperPos> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevperPOS',
      theme: CustomTheme.mainTheme(context),
      onGenerateRoute: RouterApp.generateRoute,
      initialRoute: ROOT_ROUTE,
      locale: _locale,
      supportedLocales: const [
        Locale('th', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(config: widget.config),
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
