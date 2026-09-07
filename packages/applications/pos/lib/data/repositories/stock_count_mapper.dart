// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

class StockCountMapper {
  String toStockCountRequest(CreateStockCountParam param) {
    return jsonEncode({
      'note': param.note,
      'items': param.items
          .map((item) => {
                'productId': item.productId,
                'stockId': item.stockId,
                'counted': item.counted,
              })
          .toList(),
    });
  }

  StockCount toStockCountDomain(Map<String, dynamic> json) {
    return StockCount(
      id: json['id'],
      countNo: json['countNo'] ?? '',
      note: json['note'] ?? '',
      items: toStockCountItemsDomain(json['items'] ?? []),
      createdDate: json['createdDate'],
    );
  }

  List<StockCountItem> toStockCountItemsDomain(List json) {
    return json.map((data) => toStockCountItemDomain(data)).toList();
  }

  StockCountItem toStockCountItemDomain(Map<String, dynamic> json) {
    return StockCountItem(
      productId: json['productId'],
      stockId: json['stockId'],
      systemQuantity: json['systemQuantity'],
      countedQuantity: json['countedQuantity'],
      delta: json['delta'],
    );
  }

  List<StockCount> toStockCountsDomain(List json) {
    return json.map((data) => toStockCountDomain(data)).toList();
  }
}
