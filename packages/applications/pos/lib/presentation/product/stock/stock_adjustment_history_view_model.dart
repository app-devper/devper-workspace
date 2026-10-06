// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/presentation/product/stock/stock_adjustment_history_state.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class StockAdjustmentHistoryViewModel {
  final StockAdjustmentRepository stockAdjustmentRepo;

  StockAdjustmentHistoryViewModel({
    required this.stockAdjustmentRepo,
  });

  final _state = ValueNotifier<StockAdjustmentHistoryState>(
      const StockAdjustmentHistoryState());

  ValueListenable<StockAdjustmentHistoryState> get state => _state;

  Future<void> getStockAdjustmentsByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items =
          await stockAdjustmentRepo.getStockAdjustmentsByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
