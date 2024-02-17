// Package imports:
import 'package:common/config/app_config.dart';

// Project imports:
import 'languages.dart';

class LanguageTh extends Languages {
  final AppConfig config;

  LanguageTh({required this.config});

  @override
  String get appName => "Devper POS";

  @override
  String get homeTitle => config.name;

  @override
  String get productsTitle => "รายการสินค้า";

  @override
  String get productAddTitle => "เพิ่มสินค้า";

  @override
  String get productEditTitle => "แก้ไขสินค้า";

  @override
  String get productFindTitle => "ค้นหาสินค้า";

  @override
  String get changeLanguage => "เปลี่ยนภาษา";

  @override
  String get ordersTitle => "สรุปรายการ";

  @override
  String get orderSelectEndDate => "เลือกวันที่สิ้นสุด";

  @override
  String get orderSelectStartDate => "เลือกวันที่เริ่มต้น";

  @override
  String get orderDetailTitle => "รายละเอียดรายการ";

  @override
  String get orderHistoryTitle => "ประวัติรายการ";

  @override
  String get categoryTitle => "ประเภทสินค้า";

  @override
  String get categoryAddTitle => "เพิ่มประเภทสินค้า";

  @override
  String get categoryEditTitle => "แก้ไขประเภทสินค้า";

  @override
  String get changePasswordTitle => "เปลี่ยนรหัสผ่าน";

  @override
  String get userManageTitle => "จัดการผู้ใช้งาน";

  @override
  String get userAddTitle => "เพิ่มผู้ใช้งาน";

  @override
  String get userEditTitle => "แก้ไขผู้ใช้งาน";

  @override
  String get userInfoTitle => "ข้อมูลผู้ใช้งาน";

  @override
  String get customerAddTitle => "เพิ่มลูกค้า";

  @override
  String get customerEditTitle => "แก้ไขลูกค้า";

  @override
  String get customerTitle => "ข้อมูลลูกค้า";

  @override
  String get customerManageTitle => "จัดการลูกค้า";

  @override
  String get supplierInfoTitle => "ร้านของฉัน";

  @override
  String get receiveManageTitle => "รับสินค้า";

  @override
  String get receivesTitle => "รายการรับสินค้า";

  @override
  String get productsExpiredTitle => "รายการสินค้าหมดอายุ";

  @override
  String get productLotEditTitle => "แก้ไขล็อตสินค้า";

  @override
  String get supplierAddTitle => "เพิ่มร้านค้า";

  @override
  String get supplierEditTitle => "แก้ไขร้านค้า";

  @override
  String get suppliersTitle => "จัดการร้านค้า";
}
