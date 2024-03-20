import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final bool active;
  final IconData icon;
  final Function onTap;
  final Color defaultColor;
  final double height;

  const MenuItem({
    super.key,
    required this.active,
    required this.onTap,
    required this.icon,
    this.defaultColor = const Color(0xFFB0BEC5),
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.blue : Colors.transparent;
    final colorIcon = active ? Colors.blue : defaultColor;
    final background = active ? Colors.blue[50] : Colors.transparent;
    return InkWell(
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
            child: Icon(
              icon,
              size: 30,
              color: colorIcon,
            ),
          ),
        ),
      ]),
    );
  }
}
