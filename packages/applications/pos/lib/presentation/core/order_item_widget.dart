import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/dialog_widget.dart';
import 'package:pos/presentation/product/main/product_stock_sequence_widget.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem orderItem;
  final Function onRemove;

  const OrderItemWidget({
    super.key,
    required this.orderItem,
    required this.onRemove,
  });

  @override
  State createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  late OrderItem _orderItem;

  @override
  void initState() {
    _orderItem = widget.orderItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double getValue(String value) {
      if (value.isEmpty || value == "." || value == "0") {
        return 0;
      } else {
        return double.parse(value);
      }
    }

    getTextDisplay(String value) {
      return SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(value),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      );
    }

    getStockPriceType() {
      final stock = _orderItem.priceType.stock;

      getSubtitle(ProductStock stock, ProductUnit unit) {
        if (stock.costPrice > 0 && stock.price > 0) {
          return Text('C: ฿${formatDouble(stock.costPrice)}, P: ฿${formatDouble(stock.price)}');
        } else if (stock.costPrice > 0) {
          return Text('C: ฿${formatDouble(stock.costPrice)}');
        } else if (stock.price > 0) {
          return Text('P: ฿${formatDouble(stock.price)}');
        } else {
          return Text('C: ฿${formatDouble(unit.costPrice)}');
        }
      }

      if (stock != null) {
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          title: const Text("สต็อก"),
          subtitle: getSubtitle(stock, _orderItem.product.unit),
          trailing: getTextDisplay(stock.importDate.formatDate()),
          onTap: () {
            _showEditStockSequenceDialog(
              context,
              stocks: _orderItem.product.stocks,
              unit: _orderItem.product.unit,
            );
          },
        );
      } else {
        return const ListTile(
          visualDensity: VisualDensity(vertical: -4),
          title: Text("สต็อก"),
          subtitle: Text('ไม่มีข้อมูลสต็อก'),
        );
      }
    }

    return Column(
      children: [
        ListTile(
          title: const Text('จำนวนสินค้า'),
          trailing: getTextDisplay("${_orderItem.quantity} ${_orderItem.unit}"),
          onTap: () {
            showInputNumberDialog(
              context,
              title: 'จำนวนสินค้า',
              onCompleted: (value) {
                setState(() {
                  _orderItem.updateQuantity(getValue(value));
                });
              },
            );
          },
        ),
        const Divider(height: 1),
        getStockPriceType(),
        const Divider(height: 1),
        ListTile(
          title: const Text('ราคาสินค้า'),
          trailing: getTextDisplay("฿${formatDouble(_orderItem.priceType.price)} ${_orderItem.getPriceDetail()}"),
          onTap: () {
            showBottomPopup(context, items: _orderItem.product.prices, onCompleted: (price) {
              setState(() {
                _orderItem.updatePriceType(price.customerType);
              });
            });
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('ส่วนลดสินค้า (%)'),
          trailing: getTextDisplay(_orderItem.discount > 0 ? "${formatDouble(_orderItem.discount * 100 / _orderItem.priceType.price)}%" : "-"),
          onTap: () {
            showInputNumberDialog(
              context,
              title: 'ส่วนลดสินค้า (%)',
              maxLength: 2,
              onCompleted: (value) {
                setState(() {
                  _orderItem.updateDiscountByPercent(getValue(value));
                });
              },
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('ส่วนลดสินค้า (฿)'),
          trailing: getTextDisplay(_orderItem.discount > 0 ? formatDouble(_orderItem.discount) : "-"),
          onTap: () {
            showInputNumberDialog(
              context,
              title: 'ส่วนลดสินค้า (฿)',
              onCompleted: (value) {
                setState(() {
                  _orderItem.updateDiscount(getValue(value));
                });
              },
            );
          },
        ),
        const Divider(height: 1),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 180,
            height: 40,
            child: TextButton(
              onPressed: () {
                widget.onRemove();
              },
              child: const Text(
                'ยกเลิกสินค้า',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditStockSequenceDialog(
    BuildContext context, {
    required List<ProductStock> stocks,
    required ProductUnit unit,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductStockSequenceWidget(
        stocks: stocks,
        unit: unit.unit,
        onComplete: (stock) {
          setState(() {
            _orderItem.updateProductStockSequence(stock);
          });
        },
      ),
    );
  }
}
