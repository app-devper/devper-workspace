// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/number_ext.dart';

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String barcode;
  final Function onTap;

  const ProductItem({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.barcode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = quantity > 0;
    return Card(
      elevation: 0,
      color: available ? Colors.white : const Color(0xFFF4F6F8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE0E6ED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap.call(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF243247))),
              const Spacer(),
              Text(available ? 'คงเหลือ $quantity $unit' : 'สินค้าหมด',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: available
                          ? const Color(0xFF28734A)
                          : const Color(0xFF687588))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: Text('฿${formatDouble(price)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF315E90)))),
                Flexible(
                    child: Text('/ $unit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF687588)))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final int index;
  final bool active;
  final bool haveOrder;
  final Function onTap;

  const CartItem({
    super.key,
    required this.index,
    required this.active,
    required this.haveOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.blue : Colors.transparent;
    final background = active ? Colors.blue[50] : Colors.transparent;
    return InkWell(
      onTap: () {
        onTap.call();
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              color: background,
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    index.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  haveOrder
                      ? Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          Container(height: 60, width: 3, color: color),
        ],
      ),
    );
  }
}

class CartOrderItem extends StatelessWidget {
  final String title;
  final int quantity;
  final double price;
  final String unit;
  final String priceDetail;
  final double discount;
  final bool allowOversell;
  final Function onRemove;
  final Function onAdd;
  final Function onEdit;
  final Function onEditPrice;
  final Function onToggleOversell;

  const CartOrderItem({
    super.key,
    required this.title,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.discount,
    required this.priceDetail,
    required this.allowOversell,
    required this.onRemove,
    required this.onAdd,
    required this.onEdit,
    required this.onEditPrice,
    required this.onToggleOversell,
  });

  @override
  Widget build(BuildContext context) {
    getPriceDiscount() {
      if (discount > 0) {
        return SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '฿${formatDouble(price * quantity)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                '฿${formatDouble((price * quantity) - (discount * quantity))}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '฿${formatDouble(price * quantity)}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              priceDetail,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ListTile(
          onTap: () {
            onEditPrice.call();
          },
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            unit,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          trailing: SizedBox(
            width: 288,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Tooltip(
                    message: allowOversell
                        ? "อนุญาตขายเกินสต็อกแล้ว"
                        : "อนุญาตขายเกินสต็อก",
                    child: InkResponse(
                      onTap: () {
                        onToggleOversell.call();
                      },
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: allowOversell
                              ? Colors.orange[50]
                              : Colors.grey[100],
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          allowOversell
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: allowOversell ? Colors.orange : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: InkResponse(
                    onTap: () {
                      onRemove.call();
                    },
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.red[50],
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    onEdit.call();
                  },
                  child: Container(
                    width: 50,
                    height: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${quantity}x',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: InkResponse(
                    onTap: () {
                      onAdd.call();
                    },
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.blue[50],
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                getPriceDiscount(),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
        ),
      ],
    );
  }
}
