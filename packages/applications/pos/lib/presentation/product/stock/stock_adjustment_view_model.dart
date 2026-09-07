// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/usecase/stock_adjustment/create_stock_adjustment_use_case.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_state.dart';

class StockAdjustmentViewModel {
  final CreateStockAdjustmentUseCase createStockAdjustmentUseCase;

  StockAdjustmentViewModel({
    required this.createStockAdjustmentUseCase,
  });

  final _state = ValueNotifier<StockAdjustmentState>(const StockAdjustmentState());

  ValueListenable<StockAdjustmentState> get state => _state;

  Future<void> createStockAdjustment(CreateStockAdjustmentParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearCreated: true);
    try {
      final created = await createStockAdjustmentUseCase(param);
      _state.value = _state.value.copyWith(loading: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
