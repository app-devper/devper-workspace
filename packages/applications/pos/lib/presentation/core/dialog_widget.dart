// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/dialogs.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/presentation/core/order_item_widget.dart';

void showEditOrderItemDialog(
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
