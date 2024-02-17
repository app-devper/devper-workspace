// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'order_item_detail.dart';

class OrderDetail {
  final String id;
  final double totalCost;
  final String code;
  final String customerCode;
  final String customerName;
  final String createdDate;
  final List<OrderItemDetail> items;

  OrderDetail({
    required this.id,
    required this.createdDate,
    required this.items,
    required this.totalCost,
    required this.code,
    required this.customerCode,
    required this.customerName,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }

  String getDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy");
    return format.format(date.toLocal());
  }
}
