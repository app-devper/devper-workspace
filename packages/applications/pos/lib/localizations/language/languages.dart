// Flutter imports:
import 'package:flutter/material.dart';

abstract class Languages {
  static Languages of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages)!;
  }

  String get appName;

  String get homeTitle;

  String get productsTitle;

  String get productAddTitle;

  String get productEditTitle;

  String get productFindTitle;

  String get changeLanguage;

  String get ordersTitle;

  String get orderSelectStartDate;

  String get orderSelectEndDate;

  String get orderDetailTitle;

  String get orderHistoryTitle;

  String get categoryTitle;

  String get categoryAddTitle;

  String get categoryEditTitle;

  String get changePasswordTitle;

  String get userManageTitle;

  String get userInfoTitle;

  String get userAddTitle;

  String get userEditTitle;

  String get customerManageTitle;

  String get customerTitle;

  String get customerAddTitle;

  String get customerEditTitle;

  String get supplierInfoTitle;

  String get suppliersTitle;

  String get supplierAddTitle;

  String get supplierEditTitle;

  String get receiveManageTitle;

  String get receivesTitle;

  String get productsExpiredTitle;

  String get productLotEditTitle;

  String get stockCountsTitle;

  String get stockCountManageTitle;

  String get stockCountCreateTitle;
}
