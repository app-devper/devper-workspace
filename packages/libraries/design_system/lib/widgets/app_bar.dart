// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';

AppBar buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    iconTheme: const IconThemeData(
      color: CustomColor.fontBlack,
    ),
    elevation: 0,
    backgroundColor: CustomColor.white,
    centerTitle: true,
    title: Text(title, style: buildAppBarTextStyle()),
    actions: actions,
  );
}

TextStyle buildAppBarTextStyle() {
  return const TextStyle(
    color: CustomColor.fontBlack,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
