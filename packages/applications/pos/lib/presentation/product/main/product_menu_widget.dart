// Flutter imports:
import 'package:flutter/material.dart';

class ProductMenuWidget extends StatelessWidget {
  final Function() onAdd;
  final Function() onExport;
  final Function()? onImportCsv;

  const ProductMenuWidget({
    super.key,
    required this.onAdd,
    required this.onExport,
    this.onImportCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.add,
          title: 'เพิ่มสินค้า',
          onTap: () {
            onAdd();
          },
        ),
        _buildMenuItem(
          icon: Icons.download,
          title: 'ส่งออกสินค้า',
          onTap: () {
            onExport();
          },
        ),
        if (onImportCsv != null)
          _buildMenuItem(
            icon: Icons.upload_file,
            title: 'นำเข้าจาก CSV',
            onTap: () {
              onImportCsv!();
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
}
