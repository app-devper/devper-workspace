// Flutter imports:
import 'package:flutter/material.dart';

class ReceiveMenuWidget extends StatelessWidget {
  final Function() onAdd;

  const ReceiveMenuWidget({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.add,
          title: 'เพิ่มใบรับสินค้า',
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
