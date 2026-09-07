// Package imports:
import 'package:intl/intl.dart';

class ProductReturnItem {
  String orderItemId;
  String productId;
  int quantity;
  double price;
  double refund;

  ProductReturnItem({
    required this.orderItemId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.refund,
  });
}

class ProductReturn {
  String id;
  String returnNo;
  String orderId;
  String customerCode;
  String reason;
  List<ProductReturnItem> items;
  double totalRefund;
  String createdDate;

  ProductReturn({
    required this.id,
    required this.returnNo,
    required this.orderId,
    required this.customerCode,
    required this.reason,
    required this.items,
    required this.totalRefund,
    required this.createdDate,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
