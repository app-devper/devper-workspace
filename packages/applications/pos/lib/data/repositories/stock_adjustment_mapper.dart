// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension StockAdjustmentJson on Map<String, dynamic> {
  StockAdjustment toStockAdjustmentDomain() {
    final json = this;

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
}

extension StockAdjustmentListJson on List {
  List<StockAdjustment> toStockAdjustmentsDomain() {
    final json = this;

    return json
        .map((data) => (data as Map<String, dynamic>).toStockAdjustmentDomain())
        .toList();
  }
}

extension CreateStockAdjustmentParamRequest on CreateStockAdjustmentParam {
  String toStockAdjustmentRequest() {
    final param = this;

    return jsonEncode({
      'productId': param.productId,
      'stockId': param.stockId,
      'reason': param.reason,
      'note': param.note,
      'delta': param.delta,
    });
  }
}
