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
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Card(
        shadowColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: quantity != 0 ? Colors.green : Colors.grey,
                ),
                child: Text(
                  quantity != 0 ? "$quantity${unit != "" ? " $unit" : ""}" : 'หมด',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                name,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "฿${formatDouble(price)}",
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
  final Function onRemove;
  final Function onAdd;
  final Function onEdit;
  final Function onEditPrice;

  const CartOrderItem({
    super.key,
    required this.title,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.discount,
    required this.priceDetail,
    required this.onRemove,
    required this.onAdd,
    required this.onEdit,
    required this.onEditPrice,
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
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: GestureDetector(
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                  width: 24,
                  height: 24,
                  child: GestureDetector(
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
