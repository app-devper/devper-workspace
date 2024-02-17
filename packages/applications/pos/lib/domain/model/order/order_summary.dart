// Package imports:
import 'package:intl/intl.dart';

class OrderSummary {
  final String id;
  final String customerCode;
  final String customerName;
  final String createdDate;
  final double total;
  final double totalCost;
  final String type;

  OrderSummary({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.createdDate,
    required this.total,
    required this.totalCost,
    required this.type,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
