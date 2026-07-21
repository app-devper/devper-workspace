// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/product/update_product_stock_quantity_by_id_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_state.dart';

class ProductStockQuantityViewModel {
  final UpdateProductStockQuantityByIdUseCase updateProductStockQuantityByIdUseCase;

  ProductStockQuantityViewModel({
    required this.updateProductStockQuantityByIdUseCase,
  });

  final _state = ValueNotifier<ProductStockQuantityState>(const ProductStockQuantityState());

  ValueListenable<ProductStockQuantityState> get state => _state;

  Future<void> updateProductStockQuantityById(String id, UpdateProductStockQuantityParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateProductStockQuantityByIdUseCase(
        ProductStockQuantityUpdateParam(id: id, param: param),
      );
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
