import 'package:common/core/widgets/input_number.dart';
import 'package:common/core/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:pos/presentation/core/decimal_input.dart';

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

showCenterDialog(
  BuildContext context, {
  Key? alertKey,
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

showInputNumberDialog(BuildContext context, {required Function(String) onCompleted}) {
  String number = "";
  showCenterDialog(
    context,
    minWidth: 320,
    minHeight: 430,
    maxHeight: 430,
    maxWidth: 320,
    builder: (dialogContext) => Column(
      children: [
        TitleBar(
          title: "จำนวน",
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
