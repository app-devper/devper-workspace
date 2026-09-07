import 'package:flutter/material.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/main/cart_page.dart';
import 'package:um/container.dart' as um;

// Project imports:
import 'package:pos/container.dart' as pos;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.forEnvironment("app");
  um.setupLogging();
  await um.initCore(config);
  await um.initUm();
  await pos.initPos();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      initialRoute: rootRoute,
      home: const PaymentHome(),
    );
  }
}

class PaymentHome extends StatefulWidget {
  const PaymentHome({super.key});

  @override
  State<PaymentHome> createState() => _PaymentHomeState();
}

class _PaymentHomeState extends State<PaymentHome> {
  String number = "";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CartPage());
  }
}
