// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

@immutable
class StockCountManageState {
  final bool loading;
  final String? error;

  final StockCount? stockCount;
  final List<StockCountItemParam> items;

  final StockCount? created;

  const StockCountManageState({
    this.loading = false,
    this.error,
    this.stockCount,
    this.items = const [],
    this.created,
  });

  StockCountManageState copyWith({
    bool? loading,
    String? error,
    StockCount? stockCount,
    List<StockCountItemParam>? items,
    StockCount? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return StockCountManageState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      stockCount: stockCount ?? this.stockCount,
      items: items ?? this.items,
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
