// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/stock_count.dart';

@immutable
class StockCountsState {
  final List<StockCount> items;
  final bool loading;
  final String? error;

  const StockCountsState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  StockCountsState copyWith({
    List<StockCount>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return StockCountsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
