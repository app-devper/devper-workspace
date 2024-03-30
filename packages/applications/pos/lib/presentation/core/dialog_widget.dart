import 'package:common/core/ext/number_ext.dart';
import 'package:common/core/widgets/input_number.dart';
import 'package:common/core/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/decimal_input.dart';
import 'package:pos/presentation/core/order_item_widget.dart';

showRightDialog(BuildContext context, {required WidgetBuilder builder}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: SizedBox(
            width: 360,
            height: double.infinity,
            child: builder(context),
          ),
        ),
      );
    },
  );
}

showCenterDialog({
  Key? alertKey,
  required BuildContext context,
  required WidgetBuilder builder,
  double minWidth = 640,
  double minHeight = 600,
  double maxWidth = 640,
  double maxHeight = 600,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Scaffold(
        key: alertKey,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.center,
              child: Material(
                borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    minHeight: minHeight,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: builder(dialogContext),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

showInputNumberDialog(
  BuildContext context, {
  required String title,
  required Function(String) onCompleted,
  isShowDot = false,
  maxLength = 3,
}) {
  String number = "";
  showCenterDialog(
    context: context,
    minWidth: 320,
    minHeight: 430,
    maxHeight: 430,
    maxWidth: 320,
    builder: (dialogContext) => Column(
      children: [
        TitleBar(
          title: title,
          onBack: () {
            Navigator.pop(context);
          },
          action: "ยืนยัน",
          onAction: () {
            Navigator.pop(context);
            onCompleted(number);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: DecimalInput(
            isShowDot: isShowDot,
            maxLength: maxLength,
            title: title,
            onChange: (value) {
              number = value;
            },
            onDone: (value) {
              Navigator.pop(context);
              onCompleted(value);
            },
          ),
        )
      ],
    ),
  );
}

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
