// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/product/product.dart';

class OrderItemDetail {
  String id;
  Product? product;
  int quantity;
  double price;
  double costPrice;
  double discount;
  String createdDate;
  Order? order;
  int oversoldQty;
  int returnedQty;

  OrderItemDetail({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.costPrice,
    required this.discount,
    required this.createdDate,
    required this.order,
    this.oversoldQty = 0,
    this.returnedQty = 0,
  });

  /// What the customer paid for the line: [price] is the whole line before
  /// its discount, and [discount] is so much off each unit.
  double paid() => price - discount * quantity;

  /// What the customer paid for one unit. A return refunds no more.
  double paidPerUnit() {
    if (quantity <= 0) return 0;
    final perUnit = paid() / quantity;
    return perUnit > 0 ? perUnit : 0;
  }

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
