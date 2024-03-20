// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:um/presentation/error/error_page.dart';
import 'package:um/presentation/login/login_page.dart';
import 'package:um/presentation/router.dart';

// Project imports:
import 'package:sm/presentation/constants.dart';
import 'package:sm/presentation/home/main/home_page.dart';

class RouterApp {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/um') ?? false) {
      return RouterUm.generateRoute(settings);
    } else {
      switch (settings.name) {
        case rootRoute:
          return MaterialPageRoute(builder: (_) => const LoginPage());
        case homeRoute:
          return MaterialPageRoute(builder: (_) => const HomePage());
        default:
          return MaterialPageRoute(builder: (_) => const ErrorPage());
      }
    }
  }
}
