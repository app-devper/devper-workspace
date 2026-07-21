// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

@immutable
class StockAdjustmentHistoryState {
  final List<StockAdjustment> items;
  final bool loading;
  final String? error;

  const StockAdjustmentHistoryState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  StockAdjustmentHistoryState copyWith({
    List<StockAdjustment>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return StockAdjustmentHistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
