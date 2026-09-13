// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
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

  /// Delivered once: the screen closes on it, nothing draws it.
  final _updated = OneShot<ProductStock>();
  final _errors = OneShot<String>();

  ValueListenable<ProductStockQuantityState> get state => _state;

  Stream<ProductStock> get updated => _updated.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> updateProductStockQuantityById(
      String id, UpdateProductStockQuantityParam param) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final updated = await updateProductStockQuantityByIdUseCase(
        ProductStockQuantityUpdateParam(stockId: id, param: param),
      );
      _updated.emit(updated);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }



  void dispose() {
    _state.dispose();
    _updated.dispose();
    _errors.dispose();
  }
}
