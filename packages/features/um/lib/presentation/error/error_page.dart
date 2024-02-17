// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/theme/theme.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ErrorPage extends HookWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {

    buildError(Function() onClicked) {
      buildToLoginButton() {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ButtonWidget(
            key: const Key("ToLogin"),
            onClicked: () {
              onClicked();
            },
            text: "To Login",
          ),
        );
      }

      return Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 150)),
          Text(
            "Error Page",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: CustomColor.font7,
            ),
            textAlign: TextAlign.center,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14),
          ),
          buildToLoginButton(),
        ],
      );
    }

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
