// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/stock_count/get_stock_counts_use_case.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_state.dart';

class StockCountsViewModel {
  final GetStockCountsUseCase getStockCountsUseCase;

  StockCountsViewModel({
    required this.getStockCountsUseCase,
  });

  final _state = ValueNotifier<StockCountsState>(const StockCountsState());

  ValueListenable<StockCountsState> get state => _state;

  Future<void> getStockCounts() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getStockCountsUseCase();
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
