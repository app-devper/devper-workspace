// Package imports:
import 'package:common/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:um/container.dart' as um;

// Project imports:
import 'package:pos/container.dart' as pos;
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use --dart-define=ENV=dev to load dev.json (local APIs)
  // Default is "app" which loads app.json (production)
  const env = String.fromEnvironment('ENV', defaultValue: 'app');
  final config = await AppConfig.forEnvironment(env);
  um.setupLogging();
  await um.initCore(config);
  await um.initUm();
  await pos.initPos();
  runApp(const DevperPos());
}
