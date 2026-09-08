// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/decimal_input.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_view_model.dart';

class ProductStockQuantityWidget extends StatefulWidget {
  final ProductStock stock;
  final Function(ProductStock) onComplete;

  const ProductStockQuantityWidget({
    super.key,
    required this.onComplete,
    required this.stock,
  });

  @override
  State<StatefulWidget> createState() => _ProductStockQuantityWidgetState();
}

class _ProductStockQuantityWidgetState extends State<ProductStockQuantityWidget> {
  String number = "";

  late ProductStockQuantityViewModel _viewModel;

  bool _loadingShown = false;

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      showAlertDialog(context, message, () {});
    }
    if (state.updated != null) {
      final data = state.updated!;
      _viewModel.consumeUpdated();
      Navigator.pop(context);
      widget.onComplete(data);
    }
  }

  @override
  void initState() {
    _viewModel = sl<ProductStockQuantityViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: "ปรับจำนวนคงเหลือ",
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            _updateProductStockQuantity();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: DecimalInput(
            isShowDot: false,
            maxLength: 3,
            title: "จำนวนคงเหลือ",
            onChange: (value) {
              number = value;
            },
            onDone: (value) {
              number = value;
              _updateProductStockQuantity();
            },
          ),
        )
      ],
    );
  }

  void _updateProductStockQuantity() {
    _viewModel.updateProductStockQuantityById(
      widget.stock.id,
      UpdateProductStockQuantityParam(
        quantity: number.isNotEmpty ? int.parse(number) : 0,
      ),
    );
  }
}
