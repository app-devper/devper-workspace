// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/number_ext.dart';
import 'package:design_system/widgets/input_number.dart';

// Project imports:
import 'package:design_system/theme/color.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Function(double, String) onCompleted;
  final Function onError;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.onCompleted,
    required this.onError,
  });

  @override
  State createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _typeMode = "Cash";
  String _number = "";
  double _change = 0;
  bool _isInput = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Flexible(
            child: Column(
              children: [
                Expanded(
                  child: _buildInputSection('ยอดรับเงินรวม', _getNumberFormat(_number)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountSection('ยอดที่ต้องชำระ', "฿${formatDouble(widget.amount)}"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAmountChange("เงินทอน", _change),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    _buildPaymentOption(
                      "เงินสด",
                      iconData: Icons.money,
                      isSelected: _typeMode == "Cash",
                      onTap: () {
                        setState(() {
                          _typeMode = "Cash";
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOption(
                      "พร้อมเพย์",
                      iconData: Icons.qr_code_2,
                      isSelected: _typeMode == "PromptPay",
                      onTap: () {
                        setState(() {
                          _typeMode = "PromptPay";
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: InputNumber(
                        onDone: (value) {
                          if (!_isInput) {
                            widget.onCompleted(widget.amount, _typeMode);
                          } else if (_isInput && _change >= 0) {
                            widget.onCompleted(double.parse(_number), _typeMode);
                          } else {
                            widget.onError();
                          }
                        },
                        onChange: (value) {
                          _calculate(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!_isInput) {
                          widget.onCompleted(widget.amount, _typeMode);
                        } else if (_isInput && _change >= 0) {
                          widget.onCompleted(double.parse(_number), _typeMode);
                        } else {
                          widget.onError();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.primary,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getPaymentBtn(_change),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _calculate(String value) {
    setState(() {
      _isInput = true;
      _number = value;
      if (value.isEmpty || value == "." || value == "0") {
        _change = 0 - widget.amount;
      } else {
        _change = (double.parse(value) - widget.amount);
      }
    });
  }

  String _getPaymentBtn(double value) {
    if (!_isInput && _change == 0) {
      return "รับชำระพอดี ไม่มีเงินทอน";
    } else if (_isInput && _change == 0) {
      return "รับชำระพอดี ไม่มีเงินทอน";
    } else if (_change < 0) {
      return "โปรดระบุยอดที่ต้องชำระ";
    }
    return "เงินทอน ฿${formatDouble(value)}";
  }

  String _getNumberFormat(String value) {
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
        return '${formatDecimal(double.parse(split[0]))}.${split[1]}';
      }
    }
    return formatDecimal(double.parse(value));
  }

  Widget _buildInputSection(String title, String amount) {
    getAmount() {
      if (!_isInput && amount.isEmpty) {
        return Text("฿${formatDouble(widget.amount)}", style: TextStyle(fontSize: 24, color: Colors.grey[400], fontWeight: FontWeight.bold));
      }
      return Text("฿$amount", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
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
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          getAmount(),
        ],
      ),
    );
  }

  Widget _buildAmountSection(String title, String amount) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, color: Colors.white)),
          Text(amount, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAmountChange(String title, double change) {
    getChange() {
      if (change <= 0) {
        return "";
      }
      return "฿${formatDouble(change)}";
    }

    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, color: Colors.white)),
          Text(getChange(), style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, {required IconData iconData, String? amount, bool isSelected = false, Function()? onTap}) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.green : const Color(0xFFEEEEEE), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconData, color: isSelected ? Colors.green : Colors.grey, size: 20),
                Text(title, style: TextStyle(fontSize: 16, color: isSelected ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            if (amount != null) ...[
              Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, color: Colors.green),
            ] else ...[
              const Icon(Icons.circle_outlined, color: Color(0xFFEEEEEE)),
            ],
          ],
        ),
      ),
    );
  }
}
