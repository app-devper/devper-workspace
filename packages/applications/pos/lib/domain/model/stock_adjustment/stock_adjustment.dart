// Package imports:
import 'package:intl/intl.dart';

class StockAdjustment {
  String id;
  String code;
  String productId;
  String stockId;
  String reason;
  String note;
  int delta;
  int before;
  int after;
  String createdDate;

  StockAdjustment({
    required this.id,
    required this.code,
    required this.productId,
    required this.stockId,
    required this.reason,
    required this.note,
    required this.delta,
    required this.before,
    required this.after,
    required this.createdDate,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
