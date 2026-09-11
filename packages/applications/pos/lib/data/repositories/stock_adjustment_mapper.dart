// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

class StockAdjustmentMapper {
  const StockAdjustmentMapper();

  String toStockAdjustmentRequest(CreateStockAdjustmentParam param) {
    return jsonEncode({
      'productId': param.productId,
      'stockId': param.stockId,
      'reason': param.reason,
      'note': param.note,
      'delta': param.delta,
    });
  }

  StockAdjustment toStockAdjustmentDomain(Map<String, dynamic> json) {
    return StockAdjustment(
      id: json['id'],
      code: json['code'] ?? '',
      productId: json['productId'],
      stockId: json['stockId'],
      reason: json['reason'] ?? '',
      note: json['note'] ?? '',
      delta: json['delta'],
      before: json['before'],
      after: json['after'],
      createdDate: json['createdDate'],
    );
  }

  List<StockAdjustment> toStockAdjustmentsDomain(List json) {
    return json.map((data) => toStockAdjustmentDomain(data)).toList();
  }
}
