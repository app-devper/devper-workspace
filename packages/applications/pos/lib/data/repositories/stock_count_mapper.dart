// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension StockCountJson on Map<String, dynamic> {
  StockCount toStockCountDomain() {
    final json = this;

    return StockCount(
      id: json['id'],
      countNo: json['countNo'] ?? '',
      note: json['note'] ?? '',
      items: ((json['items'] ?? []) as List).toStockCountItemsDomain(),
      createdDate: json['createdDate'],
    );
  }

  StockCountItem toStockCountItemDomain() {
    final json = this;

    return StockCountItem(
      productId: json['productId'],
      stockId: json['stockId'],
      systemQuantity: json['systemQuantity'],
      countedQuantity: json['countedQuantity'],
      delta: json['delta'],
    );
  }
}

extension StockCountListJson on List {
  List<StockCountItem> toStockCountItemsDomain() {
    final json = this;

    return json
        .map((data) => (data as Map<String, dynamic>).toStockCountItemDomain())
        .toList();
  }

  List<StockCount> toStockCountsDomain() {
    final json = this;

    return json
        .map((data) => (data as Map<String, dynamic>).toStockCountDomain())
        .toList();
  }
}

extension CreateStockCountParamRequest on CreateStockCountParam {
  String toStockCountRequest() {
    final param = this;

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
}
