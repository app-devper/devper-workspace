// Flutter imports:
import 'package:flutter/material.dart';
import 'package:design_system/theme/app_colors.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:design_system/widgets/title_bar.dart';

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

  /// The discount as a percentage of the price. A line with no price has no
  /// percentage to show — dividing by it gave Infinity or NaN.
  String _percentText() {
    final price = _orderItem.priceType.price;
    if (_orderItem.discount <= 0 || price <= 0) return "";
    return formatDouble(_orderItem.discount * 100 / price);
  }

  @override
  void initState() {
    _orderItem = widget.orderItem;
    _quantityController =
        TextEditingController(text: _orderItem.quantity.toString());
    _discountPercentController = TextEditingController(text: _percentText());
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
            Icon(Icons.arrow_drop_down,
                color: AppColors.of(context).textSecondary),
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
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          ],
          decoration: InputDecoration(
            isDense: true,
            prefixText: prefixText,
            suffixText: suffixText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: onChanged,
        ),
      );
    }

    getStockPriceType() {
      final stock = _orderItem.priceType.stock;

      getSubtitle(ProductStock stock, ProductUnit unit) {
        if (stock.costPrice > 0 && stock.price > 0) {
          return Text(
              'C: ฿${formatDouble(stock.costPrice)}, P: ฿${formatDouble(stock.price)}');
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
            _showStockPicker(context);
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
              initialValue: _orderItem.product.prices
                  .where((price) =>
                      price.customerType == _orderItem.priceType.type)
                  .firstOrNull,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  _orderItem.overridePriceType(price.customerType);
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
                _discountAmountController.text = _orderItem.discount > 0
                    ? formatDouble(_orderItem.discount)
                    : "";
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
                _discountPercentController.text = _percentText();
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
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Rings this line up against a batch the cashier picks.
  ///
  /// This used to open the Product's reorder screen, which saved a new
  /// sell-first order to the server for every till the moment it was
  /// confirmed — a catalogue change made from inside a line edit. Picking a
  /// batch now changes this line of this sale and nothing else.
  void _showStockPicker(BuildContext context) {
    final stocks = [..._orderItem.product.stocks]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final current = _orderItem.priceType.stock?.id;
    showCenterDialog(
      context: context,
      builder: (dialogContext) => Column(
        children: [
          TitleBar(
            title: "เลือกล็อต ${_orderItem.product.unit.unit}",
            onBack: () => Navigator.pop(dialogContext),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: stocks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final stock = stocks[index];
                return ListTile(
                  key: Key('stock-${stock.id}'),
                  selected: stock.id == current,
                  title: Text(stock.importDate.formatDate()),
                  subtitle: Text(
                      'ล็อต ${stock.lotNumber} · คงเหลือ ${stock.quantity}'),
                  trailing:
                      stock.id == current ? const Icon(Icons.check) : null,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _orderItem.chooseStock(stock);
                      _discountPercentController.text = _percentText();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
