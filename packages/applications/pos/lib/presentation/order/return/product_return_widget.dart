// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:pos/presentation/order/return/product_return_view_model.dart';

class ProductReturnWidget extends StatefulWidget {
  final String orderId;
  final String orderItemId;
  final String productName;
  final double price;
  final int maxReturnable;
  final Function() onComplete;

  const ProductReturnWidget({
    super.key,
    required this.orderId,
    required this.orderItemId,
    required this.productName,
    required this.price,
    required this.maxReturnable,
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() => _ProductReturnWidgetState();
}

class _ProductReturnWidgetState extends State<ProductReturnWidget> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _refundController = TextEditingController();
  final _reasonController = TextEditingController();

  late ProductReturnViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<ProductReturnViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _quantityController.text = widget.maxReturnable.toString();
    _refundController.text = (widget.price * widget.maxReturnable).toStringAsFixed(2);
    _quantityController.addListener(_onQuantityChanged);
    super.initState();
  }

  void _onQuantityChanged() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    _refundController.text = (widget.price * quantity).toStringAsFixed(2);
  }

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
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _quantityController.removeListener(_onQuantityChanged);
    _quantityController.dispose();
    _refundController.dispose();
    _reasonController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(
          title: "รับคืนสินค้า",
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
                    widget.productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'คืนได้สูงสุด ${widget.maxReturnable}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: buildInputDecoration(
                      labelText: 'จำนวนที่คืน',
                      hintText: 'โปรดระบุจำนวนที่คืน',
                    ),
                    validator: (value) {
                      final quantity = int.tryParse(value ?? '') ?? 0;
                      if (quantity <= 0) {
                        return 'โปรดระบุจำนวนที่คืน';
                      }
                      if (quantity > widget.maxReturnable) {
                        return 'คืนได้สูงสุด ${widget.maxReturnable}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    controller: _refundController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: buildInputDecoration(
                      labelText: 'จำนวนเงินคืน',
                      hintText: 'โปรดระบุจำนวนเงินคืน',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'โปรดระบุจำนวนเงินคืน';
                      }
                      if (double.tryParse(value)! < 0) {
                        return 'จำนวนเงินคืนต้องมากกว่าหรือเท่ากับ 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    controller: _reasonController,
                    decoration: buildInputDecoration(
                      labelText: 'เหตุผลการคืน',
                      hintText: 'โปรดระบุเหตุผลการคืน (ถ้ามี)',
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _viewModel.createProductReturn(
      CreateProductReturnParam(
        orderId: widget.orderId,
        reason: _reasonController.text,
        items: [
          ProductReturnItemParam(
            orderItemId: widget.orderItemId,
            quantity: int.tryParse(_quantityController.text) ?? 0,
            refund: double.tryParse(_refundController.text) ?? 0,
          ),
        ],
      ),
    );
  }
}
