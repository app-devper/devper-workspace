// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/product/update_product_stock_quantity_by_id_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_state.dart';

class ProductStockQuantityViewModel {
  final UpdateProductStockQuantityByIdUseCase
      updateProductStockQuantityByIdUseCase;

  ProductStockQuantityViewModel({
    required this.updateProductStockQuantityByIdUseCase,
  });

  final _state = ValueNotifier<ProductStockQuantityState>(
      const ProductStockQuantityState());

  ValueListenable<ProductStockQuantityState> get state => _state;

  Future<void> updateProductStockQuantityById(
      String id, UpdateProductStockQuantityParam param) async {
    _state.value =
        _state.value.copyWith(task: const ProductStockQuantityRunning());
    try {
      final updated = await updateProductStockQuantityByIdUseCase(
        ProductStockQuantityUpdateParam(stockId: id, param: param),
      );
      _state.value =
          _state.value.copyWith(task: ProductStockQuantityUpdated(updated));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductStockQuantityFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductStockQuantityFailed) {
      _state.value =
          _state.value.copyWith(task: const ProductStockQuantityTask());
    }
  }

  void consumeUpdated() {
    if (_state.value.task is ProductStockQuantityUpdated) {
      _state.value =
          _state.value.copyWith(task: const ProductStockQuantityTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
