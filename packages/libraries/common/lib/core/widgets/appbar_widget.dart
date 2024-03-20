// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/theme/theme.dart';

buildAppBar(String title, {List<Widget>? actions}) {
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

buildAppBarTextStyle() {
  return const TextStyle(
    color: CustomColor.fontBlack,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
