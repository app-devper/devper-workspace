// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:um/container.dart' as um;

// Project imports:
import 'package:sm/container.dart' as sm;
import 'package:sm/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('ENV', defaultValue: 'app');
  final config = await AppConfig.forEnvironment(env);
  um.setupLogging();
  await um.initCore(config);
  await um.initUm();
  await sm.initSm();
  runApp(DevperSm(config: config));
}
