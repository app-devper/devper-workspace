// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';

class TitleBar extends StatelessWidget {
  final String title;
  final Function onBack;
  final String? action;
  final Function? onAction;

  const TitleBar({
    super.key,
    required this.title,
    this.action,
    required this.onBack,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            onBack();
          },
          child: Container(
            width: 72,
            padding: const EdgeInsets.all(8.0),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(child: Text(
                  "ปิด",
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CustomColor.fontBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (action != null) ...[
          InkWell(
            onTap: () {
              onAction?.call();
            },
            child: Container(
              width: 72,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                action ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomColor.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] else ...[
          Container(width: 72, padding: const EdgeInsets.all(8.0)),
        ]
      ],
    );
  }
}
