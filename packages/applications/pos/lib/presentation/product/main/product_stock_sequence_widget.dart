import 'dart:ui';

import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/theme/theme.dart';
import 'package:common/core/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/main/product_stock_sequence_state.dart';
import 'package:pos/presentation/product/main/product_stock_sequence_view_model.dart';

class ProductStockSequenceWidget extends StatefulWidget {
  final String unit;
  final List<ProductStock> stocks;
  final Function(List<ProductStock>) onComplete;

  const ProductStockSequenceWidget({
    super.key,
    required this.stocks,
    required this.onComplete,
    required this.unit,
  });

  @override
  State<ProductStockSequenceWidget> createState() => _ProductStockSequenceWidgetState();
}

class _ProductStockSequenceWidgetState extends State<ProductStockSequenceWidget> {
  List<ProductStock> _items = [];
  late ProductStockSequenceViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<ProductStockSequenceViewModel>();
    _viewModel.states.listen((state) {
      if (state is LoadingState) {
        showLoadingDialog(context);
      } else if (state is ErrorState) {
        hideLoadingDialog(context);
        showAlertDialog(context, state.message, () {});
      } else if (state is UpdateProductSequenceState) {
        hideLoadingDialog(context);
        Navigator.pop(context);
        widget.onComplete(state.data);
      }
    });
    _items = widget.stocks;
    _items.sort((a, b) => a.sequence.compareTo(b.sequence));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget proxyDecorator(
      Widget child,
      int index,
      Animation<double> animation,
    ) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: Colors.grey.withOpacity(animValue * 0.1),
            shadowColor: Colors.grey.withOpacity(animValue * 0.1),
            child: child,
          );
        },
        child: child,
      );
    }

    return Column(
      children: [
        TitleBar(
          title: "จัดเรียงสต็อก ${widget.unit}",
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            if (_items.isNotEmpty) {
              _viewModel.updateProductStockSequenceById(_getUpdateProductStockSequenceParam());
            } else {
              Navigator.pop(context);
            }
          },
        ),
        const Divider(height: 1),
        Expanded(
            child: ReorderableListView(
          proxyDecorator: proxyDecorator,
          children: <Widget>[
            for (int index = 0; index < _items.length; index += 1)
              Column(key: Key('$index'), children: [
                ListTile(
                  leading: Text(
                    '${index + 1}#',
                    style: const TextStyle(
                      color: CustomColor.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text("สต็อกเมื่อวันที่ ${_items[index].importDate.formatDate()} (คงเหลือ ${_items[index].quantity} ${widget.unit})"),
                  subtitle: _getSubtitle(_items[index], widget.unit),
                ),
                const Divider(height: 1),
              ])
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final ProductStock item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
          },
        ))
      ],
    );
  }

  _getSubtitle(ProductStock stock, String unit) {
    const style = TextStyle(color: Colors.grey, fontSize: 14);
    if (stock.costPrice > 0 && stock.price > 0) {
      return Text('Cost: ฿${formatDouble(stock.costPrice)}, Price: ฿${formatDouble(stock.price)}', style: style);
    } else if (stock.costPrice > 0) {
      return Text('Cost: ฿${formatDouble(stock.costPrice)}', style: style);
    } else if (stock.price > 0) {
      return Text('Price: ฿${formatDouble(stock.price)}', style: style);
    } else {
      return Text('จำนวนที่นำเข้า: ${stock.import} $unit', style: style);
    }
  }

  _getUpdateProductStockSequenceParam() {
    return UpdateProductStockSequenceParam(
      productId: _items.first.productId,
      stocks: _items.map((e) => ProductStockSequenceParam(stockId: e.id, sequence: _items.indexOf(e) + 1)).toList(),
    );
  }
}
