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

  OrderItemDetail({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.costPrice,
    required this.discount,
    required this.createdDate,
    required this.order,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
