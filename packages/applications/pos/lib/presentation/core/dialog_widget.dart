// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/dialogs.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/sale/line_edit.dart';
import 'package:pos/presentation/core/order_item_widget.dart';

/// Opens the line dialog on a draft of [orderItem].
///
/// Everything the cashier types changes the draft only. Confirming hands back
/// what changed; backing out throws the draft away, and the Sale never saw it.
void showEditOrderItemDialog(
  BuildContext context, {
  required OrderItem orderItem,
  required Function(LineEdit) onCompleted,
  required Function() onRemove,
}) {
  final draft = orderItem.copy();
  showCenterDialog(
    context: context,
    minWidth: 420,
    minHeight: 560,
    maxHeight: 560,
    maxWidth: 420,
    builder: (dialogContext) => Column(
      children: [
        TitleBar(
          title: draft.product.name,
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            Navigator.pop(context);
            onCompleted(LineEdit.of(draft));
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: OrderItemWidget(
            orderItem: draft,
            onRemove: () {
              Navigator.pop(context);
              onRemove();
            },
          ),
        )
      ],
    ),
  );
}
