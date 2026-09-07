// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_widget.dart';

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
  late TextEditingController _quantityController;
  late TextEditingController _discountPercentController;
  late TextEditingController _discountAmountController;

  double getValue(String value) {
    if (value.isEmpty || value == "." || value == "0") {
      return 0;
    } else {
      return double.parse(value);
    }
  }

  @override
  void initState() {
    _orderItem = widget.orderItem;
    _quantityController = TextEditingController(text: _orderItem.quantity.toString());
    _discountPercentController = TextEditingController(
      text: _orderItem.discount > 0 ? formatDouble(_orderItem.discount * 100 / _orderItem.priceType.price) : "",
    );
    _discountAmountController = TextEditingController(
      text: _orderItem.discount > 0 ? formatDouble(_orderItem.discount) : "",
    );
    super.initState();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountPercentController.dispose();
    _discountAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    Widget buildInlineNumberField({
      required TextEditingController controller,
      required void Function(String) onChanged,
      String? prefixText,
      String? suffixText,
    }) {
      return SizedBox(
        width: 140,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.end,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            isDense: true,
            prefixText: prefixText,
            suffixText: suffixText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: onChanged,
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
          trailing: buildInlineNumberField(
            controller: _quantityController,
            suffixText: _orderItem.unit,
            onChanged: (value) {
              setState(() {
                _orderItem.updateQuantity(getValue(value));
              });
            },
          ),
        ),
        const Divider(height: 1),
        getStockPriceType(),
        const Divider(height: 1),
        ListTile(
          title: const Text('ราคาสินค้า'),
          trailing: SizedBox(
            width: 200,
            child: DropdownButtonFormField<ProductPrice>(
              isDense: true,
              isExpanded: true,
              initialValue: _orderItem.product.prices.where((price) => price.customerType == _orderItem.priceType.type).firstOrNull,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: _orderItem.product.prices
                  .map((price) => DropdownMenuItem<ProductPrice>(
                        value: price,
                        child: Text(
                          "฿${formatDouble(price.price)} ${price.getCustomerTypePrice()}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (price) {
                if (price == null) {
                  return;
                }
                setState(() {
                  _orderItem.updatePriceType(price.customerType);
                });
              },
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('ส่วนลดสินค้า (%)'),
          trailing: buildInlineNumberField(
            controller: _discountPercentController,
            suffixText: '%',
            onChanged: (value) {
              setState(() {
                _orderItem.updateDiscountByPercent(getValue(value));
                _discountAmountController.text = _orderItem.discount > 0 ? formatDouble(_orderItem.discount) : "";
              });
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('ส่วนลดสินค้า (฿)'),
          trailing: buildInlineNumberField(
            controller: _discountAmountController,
            prefixText: '฿',
            onChanged: (value) {
              setState(() {
                _orderItem.updateDiscount(getValue(value));
                _discountPercentController.text =
                    _orderItem.discount > 0 ? formatDouble(_orderItem.discount * 100 / _orderItem.priceType.price) : "";
              });
            },
          ),
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
