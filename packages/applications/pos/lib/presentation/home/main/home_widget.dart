// Flutter imports:
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final Function onTap;
  final Color defaultColor;
  final double height;

  const MenuItem({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    required this.icon,
    this.defaultColor = const Color(0xFFB0BEC5),
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.blue : Colors.transparent;
    final colorIcon = active ? Colors.blue : defaultColor;
    final background = active ? Colors.blue[50] : Colors.transparent;
    return Tooltip(
        message: label,
      excludeFromSemantics: true,
        child: Semantics(
                selected: active,
            button: true,
            child: InkWell(
              onTap: () {
                onTap.call();
              },
              child: Row(children: [
                Container(height: height, width: 3, color: color),
                Expanded(
                  child: Container(
                    height: height,
                    color: background,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 25, color: colorIcon),
                        const SizedBox(height: 4),
                        Text(label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color: active
                                    ? Colors.blue.shade800
                                    : Colors.blueGrey.shade700)),
                      ],
                    ),
                  ),
                ),
              ]),
            )));
  }
}
