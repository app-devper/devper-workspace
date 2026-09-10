// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/product/update_product_stock_sequence_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_state.dart';

class ProductStockSequenceViewModel {
  final UpdateProductStockSequenceUseCase updateProductStockSequenceUseCase;

  ProductStockSequenceViewModel({
    required this.updateProductStockSequenceUseCase,
  });

  final _state = ValueNotifier<ProductStockSequenceState>(
      const ProductStockSequenceState());

  ValueListenable<ProductStockSequenceState> get state => _state;

  Future<void> updateProductStockSequenceById(
      UpdateProductStockSequenceParam param) async {
    _state.value =
        _state.value.copyWith(task: const ProductStockSequenceRunning());
    try {
      final updated = await updateProductStockSequenceUseCase(param);
      _state.value =
          _state.value.copyWith(task: ProductStockSequenceUpdated(updated));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductStockSequenceFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductStockSequenceFailed) {
      _state.value =
          _state.value.copyWith(task: const ProductStockSequenceTask());
    }
  }

  void consumeUpdated() {
    if (_state.value.task is ProductStockSequenceUpdated) {
      _state.value =
          _state.value.copyWith(task: const ProductStockSequenceTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
