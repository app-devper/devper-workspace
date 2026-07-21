// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

@immutable
class StockAdjustmentState {
  final bool loading;
  final String? error;
  final StockAdjustment? created;

  const StockAdjustmentState({
    this.loading = false,
    this.error,
    this.created,
  });

  StockAdjustmentState copyWith({
    bool? loading,
    String? error,
    StockAdjustment? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return StockAdjustmentState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
