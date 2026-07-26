// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/main/menu_event.dart';

class HomeDatabasePage extends StatelessWidget {
  final Function(MenuEvent) onMenuTap;

  const HomeDatabasePage({
    super.key,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.store,
          title: 'ร้านค้าของฉัน',
          onTap: () {
            _nextToStoreInfo(context);
          },
        ),
        _buildMenuItem(
          icon: Icons.person,
          title: 'จัดการลูกค้า',
          onTap: () {
            onMenuTap(MenuEvent.customer);
          },
        ),
        _buildMenuItem(
          icon: Icons.account_box,
          title: 'จัดการผู้ใช้งาน',
          onTap: () {
            _nextToUserManagement(context);
          },
        ),
        _buildMenuItem(
          icon: Icons.receipt_long,
          title: 'ใบรับสินค้า / Goods Receipt',
          onTap: () {
            onMenuTap(MenuEvent.receive);
          },
        ),
        _buildMenuItem(
          icon: Icons.fact_check,
          title: 'นับสต็อก',
          onTap: () {
            _nextToStockCounts(context);
          },
        ),
      ],
    );
  }

  _buildMenuItem(
      {required IconData icon,
      required String title,
      required Null Function() onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title, style: const TextStyle(fontSize: 20)),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  _nextToUserManagement(BuildContext context) {
    Navigator.pushNamed(context, routeUsers);
  }

  _nextToStoreInfo(BuildContext context) {
    Navigator.pushNamed(context, supplierRoute);
  }

  _nextToStockCounts(BuildContext context) {
    Navigator.pushNamed(context, stockCountsRoute);
  }
}
