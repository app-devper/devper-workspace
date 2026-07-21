// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/widgets/decimal_input.dart';
import 'package:design_system/widgets/title_bar.dart';

showRightDialog(BuildContext context, {required WidgetBuilder builder}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth < 360 ? screenWidth : 360.0;
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: builder(context),
          ),
        ),
      );
    },
  );
}

showCenterDialog({
  Key? alertKey,
  required BuildContext context,
  required WidgetBuilder builder,
  double minWidth = 640,
  double minHeight = 600,
  double maxWidth = 640,
  double maxHeight = 600,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      // Callers pass fixed pixel sizes (often minWidth == maxWidth), which is fine on
      // desktop but forces an exact size regardless of how small the viewport is on a
      // phone. Clamp against 90% of the actual screen so the dialog never demands more
      // room than is available, instead of overflowing off both edges.
      final screenSize = MediaQuery.of(dialogContext).size;
      final resolvedMaxWidth = maxWidth > screenSize.width * 0.9 ? screenSize.width * 0.9 : maxWidth;
      final resolvedMaxHeight = maxHeight > screenSize.height * 0.9 ? screenSize.height * 0.9 : maxHeight;
      final resolvedMinWidth = minWidth > resolvedMaxWidth ? resolvedMaxWidth : minWidth;
      final resolvedMinHeight = minHeight > resolvedMaxHeight ? resolvedMaxHeight : minHeight;
      return Scaffold(
        key: alertKey,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.center,
              child: Material(
                borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: resolvedMinWidth,
                    minHeight: resolvedMinHeight,
                    maxWidth: resolvedMaxWidth,
                    maxHeight: resolvedMaxHeight,
                  ),
                  child: builder(dialogContext),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

showInputNumberDialog(
  BuildContext context, {
  required String title,
  required Function(String) onCompleted,
  isShowDot = false,
  maxLength = 3,
}) {
  String number = "";
  showCenterDialog(
    context: context,
    minWidth: 320,
    minHeight: 430,
    maxHeight: 430,
    maxWidth: 320,
    builder: (dialogContext) => Column(
      children: [
        TitleBar(
          title: title,
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            Navigator.pop(context);
            onCompleted(number);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: DecimalInput(
            isShowDot: isShowDot,
            maxLength: maxLength,
            title: title,
            onChange: (value) {
              number = value;
            },
            onDone: (value) {
              Navigator.pop(context);
              onCompleted(value);
            },
          ),
        )
      ],
    ),
  );
}
