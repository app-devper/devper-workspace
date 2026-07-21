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
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: SizedBox(
            width: 360,
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
                    minWidth: minWidth,
                    minHeight: minHeight,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
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
