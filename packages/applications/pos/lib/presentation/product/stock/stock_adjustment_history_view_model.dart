// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/stock_adjustment/get_stock_adjustments_by_product_id_use_case.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_state.dart';

class StockAdjustmentHistoryViewModel {
  final GetStockAdjustmentsByProductIdUseCase getStockAdjustmentsByProductIdUseCase;

  StockAdjustmentHistoryViewModel({
    required this.getStockAdjustmentsByProductIdUseCase,
  });

  final _state = ValueNotifier<StockAdjustmentHistoryState>(const StockAdjustmentHistoryState());

  ValueListenable<StockAdjustmentHistoryState> get state => _state;

  Future<void> getStockAdjustmentsByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getStockAdjustmentsByProductIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
