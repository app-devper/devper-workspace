import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputNumber extends StatefulWidget {
  final Function(String) onChange;
  final Function(String) onDone;
  final int maxLength;
  final int maxDigit;
  final bool isShowDot;

  const InputNumber({
    super.key,
    required this.onChange,
    this.maxLength = 7,
    this.maxDigit = 2,
    this.isShowDot = true,
    required this.onDone,
  });

  @override
  State createState() => _InputNumberState();
}

class _InputNumberState extends State<InputNumber> {
  String _number = "";
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    input(String num) {
      if (_number == "0" && num != ".") {
        return;
      }
      if (_number.contains(".")) {
        final split = _number.split(".");
        if (split[1].length == widget.maxDigit || num == ".") {
          return;
        }
      } else if (_number.length == widget.maxLength && num != ".") {
        return;
      }
      _number = _number + num;
      widget.onChange(_number);
    }

    delete() {
      if (_number.isNotEmpty) {
        _number = _number.substring(0, _number.length - 1);
        widget.onChange(_number);
      }
    }

    Widget getChild(String? number, Widget? icon) {
      if (icon != null) {
        return icon;
      } else {
        return Text(
          number?.toString() ?? "",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      }
    }

    Widget buildNumberButton({String? number, Widget? icon, Function()? onPressed}) {
      return Expanded(
        child: TextButton(
          key: icon?.key ?? Key("btn_$number"),
          onPressed: onPressed,
          style: TextButton.styleFrom(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide.none,
            ),
          ),
          child: getChild(number, icon),
        ),
      );
    }

    Widget buildHeightLine() {
      return Container(width: 2, height: double.infinity, color: Colors.grey[200]);
    }

    Widget buildWidthLine() {
      return Container(width: double.infinity, height: 2, color: Colors.grey[200]);
    }

    Widget buildFirstRow() {
      return Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeightLine(),
            buildNumberButton(
              number: "1",
              onPressed: () => input("1"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "2",
              onPressed: () => input("2"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "3",
              onPressed: () => input("3"),
            ),
            buildHeightLine(),
          ],
        ),
      );
    }

    Widget buildSecondRow() {
      return Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeightLine(),
            buildNumberButton(
              number: "4",
              onPressed: () => input("4"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "5",
              onPressed: () => input("5"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "6",
              onPressed: () => input("6"),
            ),
            buildHeightLine(),
          ],
        ),
      );
    }

    Widget buildThirdRow() {
      return Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeightLine(),
            buildNumberButton(
              number: "7",
              onPressed: () => input("7"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "8",
              onPressed: () => input("8"),
            ),
            buildHeightLine(),
            buildNumberButton(
              number: "9",
              onPressed: () => input("9"),
            ),
            buildHeightLine(),
          ],
        ),
      );
    }

    Widget buildSpecialRow() {
      return Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeightLine(),
            widget.isShowDot
                ? buildNumberButton(
                    number: ".",
                    onPressed: () => input("."),
                  )
                : buildNumberButton(
                    number: "",
                    onPressed: () => input(""),
                  ),
            buildHeightLine(),
            buildNumberButton(
              number: "0",
              onPressed: () => input("0"),
            ),
            buildHeightLine(),
            buildNumberButton(
              icon: const Icon(
                Icons.backspace_outlined,
                color: Colors.black,
              ),
              onPressed: () => delete(),
            ),
            buildHeightLine(),
          ],
        ),
      );
    }

    FocusScope.of(context).requestFocus(_focusNode);
    return KeyboardListener(
      focusNode: _focusNode,
      includeSemantics: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.delete) {
            delete();
          }
          if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {
            input("1");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
            input("2");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit3 || event.logicalKey == LogicalKeyboardKey.numpad3) {
            input("3");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit4 || event.logicalKey == LogicalKeyboardKey.numpad4) {
            input("4");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit5 || event.logicalKey == LogicalKeyboardKey.numpad5) {
            input("5");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit6 || event.logicalKey == LogicalKeyboardKey.numpad6) {
            input("6");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit7 || event.logicalKey == LogicalKeyboardKey.numpad7) {
            input("7");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit8 || event.logicalKey == LogicalKeyboardKey.numpad8) {
            input("8");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit9 || event.logicalKey == LogicalKeyboardKey.numpad9) {
            input("9");
          }
          if (event.logicalKey == LogicalKeyboardKey.digit0 || event.logicalKey == LogicalKeyboardKey.numpad0) {
            input("0");
          }
          if (event.logicalKey == LogicalKeyboardKey.period || event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
            if (widget.isShowDot) {
              input(".");
            }
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
           widget.onDone(_number);
          }
        }
      },
      autofocus: true,
      child: Column(
        children: [
          buildWidthLine(),
          buildFirstRow(),
          buildWidthLine(),
          buildSecondRow(),
          buildWidthLine(),
          buildThirdRow(),
          buildWidthLine(),
          buildSpecialRow(),
          buildWidthLine(),
        ],
      ),
    );
  }
}
