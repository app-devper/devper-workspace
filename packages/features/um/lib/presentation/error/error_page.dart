// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ErrorPage extends HookWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    buildBody() {
      final Size size = MediaQuery.of(context).size;
      return SafeArea(
        bottom: true,
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(20),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          "Error",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CustomColor.font7,
          ),
        ),
      ),
      body: buildBody(),
    );
  }
}
