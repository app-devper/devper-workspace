// Package imports:
import 'package:intl/intl.dart';

class StockCountItem {
  String productId;
  String stockId;
  int systemQuantity;
  int countedQuantity;
  int delta;

  StockCountItem({
    required this.productId,
    required this.stockId,
    required this.systemQuantity,
    required this.countedQuantity,
    required this.delta,
  });
}

class StockCount {
  String id;
  String countNo;
  String note;
  List<StockCountItem> items;
  String createdDate;

  StockCount({
    required this.id,
    required this.countNo,
    required this.note,
    required this.items,
    required this.createdDate,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
