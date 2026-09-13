// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/stock_count.dart';

@immutable
class StockCountsState {
  final List<StockCount> items;
  final bool loading;

  const StockCountsState({
    this.items = const [],
    this.loading = false,
  });

  StockCountsState copyWith({
    List<StockCount>? items,
    bool? loading,
  }) {
    return StockCountsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}
