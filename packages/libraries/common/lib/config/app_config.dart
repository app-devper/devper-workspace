// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

class AppConfig {
  final String apiUrl;
  final String hostApp; // optional pinned host (takes priority over the UM system host)
  final String logo;
  final String name;
  final String system;
  final String home;

  AppConfig({
    required this.apiUrl,
    this.hostApp = '',
    required this.logo,
    required this.name,
    required this.system,
    required this.home,
  });

  static Future<AppConfig> forEnvironment(String? env) async {
    // set default to app if nothing was passed
    env = env ?? 'app';

    // load the json file
    final contents = await rootBundle.loadString(
      'config/$env.json',
    );

    // decode our json
    final json = jsonDecode(contents);

    // convert our JSON into an instance of our AppConfig class
    return AppConfig(
      apiUrl: json['apiUrl'],
      hostApp: json['hostApp'] ?? '',
      logo: json['logo'],
      name: json['name'],
      system: json['system'],
      home: json['home'],
    );
  }
}
