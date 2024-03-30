// Flutter imports:
import 'package:flutter/material.dart';

class CustomerMenuWidget extends StatelessWidget {
  final Function() onAdd;
  final Function() onExport;

  const CustomerMenuWidget({
    super.key,
    required this.onAdd,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.add,
          title: 'เพิ่มลูกค้า',
          onTap: () {
            onAdd();
          },
        ),
      ],
    );
  }

  _buildMenuItem({required IconData icon, required String title, required Null Function() onTap}) {
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
}
