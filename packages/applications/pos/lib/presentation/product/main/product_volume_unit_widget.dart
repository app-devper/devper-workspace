import 'package:common/core/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/model/core/core.dart';

class ProductVolumeUnitWidget extends StatefulWidget {
  final String unit;
  final Function(String) onSelected;

  const ProductVolumeUnitWidget({
    super.key,
    required this.unit,
    required this.onSelected,
  });

  @override
  State createState() => _ProductVolumeUnitWidgetState();
}

class _ProductVolumeUnitWidgetState extends State<ProductVolumeUnitWidget> {
  int _selectedUnit = 0;

  @override
  void initState() {
    final index = volumeUnits.indexWhere((element) => element.type == widget.unit);
    if (index != -1) {
      _selectedUnit = index;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TitleBar(
        title: "ปริมาณ/น้ำหนัก",
        onBack: () {
          Navigator.of(context).pop();
        },
        action: 'ยืนยัน',
        onAction: () {
          Navigator.of(context).pop();
          widget.onSelected(volumeUnits[_selectedUnit].type);
        },
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView(
          children: [
            for (var unit in volumeUnits)
              _buildUnitOption(
                volumeUnits.indexOf(unit),
                unit.name,
              )
          ],
        ),
      )
    ]);
  }

  Widget _buildUnitOption(int index, String unitName) {
    return ListTile(
      title: Text(unitName),
      leading: Radio(
        value: index,
        groupValue: _selectedUnit,
        onChanged: (value) {},
      ),
      onTap: () {
        setState(() {
          _selectedUnit = index;
        });
      },
    );
  }
}
