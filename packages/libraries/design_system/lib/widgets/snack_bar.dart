// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';

class CustomSnackBar {
  final BuildContext context;
  final Key key;

  CustomSnackBar({required this.key, required this.context});

  void showErrorSnackBar(final Object? msg, {bool action = false}) {
    showSnackBar(text: "Error: $msg", color: Colors.red[400], action: action);
  }

  void showLoadingSnackBar() {
    hideAll();
    final snackBar = SnackBar(
      key: key,
      elevation: 8.0,
      content: Row(
        children: const <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CustomColor.white,
            ),
          ),
          SizedBox(width: 12.0),
          Text("กำลังโหลด..."),
        ],
      ),
      // Green reads as "done"; loading is neutral. The duration is only a
      // safety net for a missed hideAll, so it need not run for a minute.
      backgroundColor: CustomColor.fontBlack,
      duration: const Duration(seconds: 20),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSnackBar({
    required String text,
    Duration duration = const Duration(seconds: 3),
    Color? color,
    bool action = true,
  }) {
    hideAll();
    final snackBar = SnackBar(
      key: key,
      elevation: 8.0,
      content: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: color ?? Colors.green[400],
      duration: duration,
      action: action
          ? SnackBarAction(
              label: "Clear",
              textColor: Colors.black,
              onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
            )
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void hideAll() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
}
