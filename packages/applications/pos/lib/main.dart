// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:um/container.dart' as um;

// Project imports:
import 'package:pos/container.dart' as pos;
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.forEnvironment("app");
  um.setupLogging();
  await um.initCore(config);
  await um.initUm();
  await pos.initPos();
  runApp(DevperPos(config: config));
}
