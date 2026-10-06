// Flutter imports:
import 'package:flutter/material.dart';

AppBar buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    elevation: 0,
    centerTitle: false,
    title: Text(title, style: buildAppBarTextStyle()),
    actions: actions,
  );
}

TextStyle buildAppBarTextStyle() {
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}
