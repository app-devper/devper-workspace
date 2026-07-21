// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/number_ext.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/order_item_widget.dart';

showEditOrderItemDialog(
  BuildContext context, {
  required OrderItem orderItem,
  required Function(OrderItem) onCompleted,
  required Function() onRemove,
}) {
  showCenterDialog(
    context: context,
    minWidth: 420,
    minHeight: 560,
    maxHeight: 560,
    maxWidth: 420,
    builder: (dialogContext) => Column(
      children: [
        TitleBar(
          title: orderItem.product.name,
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            Navigator.pop(context);
            onCompleted(orderItem);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: OrderItemWidget(
            orderItem: orderItem,
            onRemove: (){
              Navigator.pop(context);
              onRemove();
            },
          ),
        )
      ],
    ),
  );
}

void showBottomPopup(BuildContext context, {required List<ProductPrice> items, required Function(ProductPrice) onCompleted}) {
  final alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    title: const Text(
      "ราคาสินค้า",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    titlePadding: const EdgeInsets.all(16),
    content: Wrap(
      children: <Widget>[
        for (var item in items)
          ListTile(
            title: Text("฿${formatDouble(item.price)} ${item.getCustomerTypePrice()}"),
            onTap: () {
              Navigator.of(context).pop();
              onCompleted(item);
            },
          ),
      ],
    ),
    contentPadding: const EdgeInsets.all(0),
    actions: [
      SizedBox(
        width: 80,
        height: 36,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext bc) {
      return alert;
    },
  );
}
