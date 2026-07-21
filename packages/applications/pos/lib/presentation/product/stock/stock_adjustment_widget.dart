// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/dropdown_input.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_view_model.dart';

class StockAdjustmentWidget extends StatefulWidget {
  final ProductStock stock;
  final Function() onComplete;

  const StockAdjustmentWidget({
    super.key,
    required this.stock,
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() => _StockAdjustmentWidgetState();
}

class _StockAdjustmentWidgetState extends State<StockAdjustmentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _deltaController = TextEditingController();
  final _deltaFocus = FocusNode();
  final _noteController = TextEditingController();
  final _noteFocus = FocusNode();

  String? _reason;
  bool _isIncrease = true;

  late StockAdjustmentViewModel _viewModel;

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading) {
      showLoadingDialog(context);
    } else {
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      showAlertDialog(context, message, () {});
    }
    if (state.created != null) {
      _viewModel.consumeCreated();
      Navigator.of(context).pop();
      widget.onComplete();
    }
  }

  @override
  void initState() {
    _viewModel = sl<StockAdjustmentViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _deltaController.dispose();
    _deltaFocus.dispose();
    _noteController.dispose();
    _noteFocus.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(
          title: "ปรับสต็อกสินค้า",
          onBack: () {
            Navigator.of(context).pop();
          },
          action: 'ยืนยัน',
          onAction: _submit,
        ),
        const Divider(height: 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ล็อต ${widget.stock.lotNumber} คงเหลือ ${widget.stock.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownInput<String>(
                    hintText: 'เหตุผลการปรับสต็อก',
                    options: stockAdjustmentReasons,
                    value: _reason,
                    getLabel: (value) => value,
                    onChanged: (value) {
                      setState(() {
                        _reason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ToggleButtons(
                    isSelected: [_isIncrease, !_isIncrease],
                    onPressed: (index) {
                      setState(() {
                        _isIncrease = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('เพิ่มสต็อก'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ลดสต็อก'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    focusNode: _deltaFocus,
                    controller: _deltaController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: buildInputDecoration(
                      labelText: 'จำนวน',
                      hintText: 'โปรดระบุจำนวนที่ต้องการปรับ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                        return 'โปรดระบุจำนวนที่ต้องการปรับ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    focusNode: _noteFocus,
                    controller: _noteController,
                    decoration: buildInputDecoration(
                      labelText: 'หมายเหตุ',
                      hintText: 'โปรดระบุหมายเหตุ (ถ้ามี)',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_reason == null) {
      showAlertDialog(context, 'โปรดระบุเหตุผลการปรับสต็อก', () {});
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final magnitude = int.tryParse(_deltaController.text) ?? 0;
    final delta = _isIncrease ? magnitude : -magnitude;
    _viewModel.createStockAdjustment(
      CreateStockAdjustmentParam(
        productId: widget.stock.productId,
        stockId: widget.stock.id,
        reason: _reason!,
        note: _noteController.text,
        delta: delta,
      ),
    );
  }
}
