// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:design_system/widgets/input_number.dart';

class DecimalInput extends StatefulWidget {
  final String title;
  final bool isShowDot;
  final int maxLength;
  final Function(String) onDone;
  final Function(String) onChange;

  const DecimalInput({
    super.key,
    required this.title,
    required this.onChange,
    required this.onDone,
    required this.isShowDot,
    this.maxLength = 3,
  });

  @override
  State createState() => _DecimalInputState();
}

class _DecimalInputState extends State<DecimalInput> {
  String _number = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _buildInputSection(
              widget.title,
              _getNumberFormat(_number),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: InputNumber(
              maxLength: widget.maxLength,
              isShowDot: widget.isShowDot,
              onChange: (value) {
                setState(() {
                  _number = value;
                });
                widget.onChange(value);
              },
              onDone: (value) {
                widget.onDone(_number);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDecimal(double value) {
    return NumberFormat("#,##0", "en_US").format(value);
  }

  _getNumberFormat(String value) {
    if (value.isEmpty) {
      return "";
    }
    if (value == ".") {
      return ".";
    }
    if (value.contains('.')) {
      final split = value.split('.');
      if (split[0] == "") {
        return '.${split[1]}';
      } else {
        return '${_formatDecimal(double.parse(split[0]))}.${split[1]}';
      }
    }
    return _formatDecimal(double.parse(value));
  }

  Widget _buildInputSection(String title, String amount) {
    getAmount() {
      return Text(
        amount,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          getAmount(),
        ],
      ),
    );
  }
}
