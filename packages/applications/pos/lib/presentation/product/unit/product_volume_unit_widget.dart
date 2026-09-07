// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
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
        child: RadioGroup<int>(
          groupValue: _selectedUnit,
          onChanged: _onUnitSelected,
          child: ListView(
            children: [
              for (var unit in volumeUnits)
                _buildUnitOption(
                  volumeUnits.indexOf(unit),
                  unit.name,
                )
            ],
          ),
        ),
      )
    ]);
  }

  void _onUnitSelected(int? index) {
    if (index == null) return;
    setState(() {
      _selectedUnit = index;
    });
  }

  Widget _buildUnitOption(int index, String unitName) {
    return ListTile(
      title: Text(unitName),
      leading: Radio<int>(value: index),
      onTap: () => _onUnitSelected(index),
    );
  }
}
