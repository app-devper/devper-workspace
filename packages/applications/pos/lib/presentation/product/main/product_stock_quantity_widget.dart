// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/decimal_input.dart';
import 'package:pos/presentation/product/main/product_stock_quantity_state.dart';
import 'package:pos/presentation/product/main/product_stock_quantity_view_model.dart';

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

  @override
  void initState() {
    _viewModel = sl<ProductStockQuantityViewModel>();
    _viewModel.states.listen((state) {
      if (state is LoadingState) {
        showLoadingDialog(context);
      } else if (state is ErrorState) {
        hideLoadingDialog(context);
        showAlertDialog(context, state.message, () {});
      } else if (state is UpdateProductStockState) {
        hideLoadingDialog(context);
        Navigator.pop(context);
        widget.onComplete(state.data);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
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

  _updateProductStockQuantity() {
    _viewModel.updateProductStockQuantityById(
      widget.stock.id,
      UpdateProductStockQuantityParam(
        quantity: number.isNotEmpty ? int.parse(number) : 0,
      ),
    );
  }
}
