// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/add_product_stock_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_stocks_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_stock_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_by_id_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_state.dart';

class ProductStockViewModel {
  final AddProductStockUseCase addProductStockUseCase;
  final UpdateProductStockByIdUseCase updateProductStockByIdUseCase;
  final RemoveProductStockByIdUseCase removeProductStockByIdUseCase;
  final GetProductStocksByProductIdUseCase getProductStocksByProductIdUseCase;

  ProductStockViewModel({
    required this.addProductStockUseCase,
    required this.updateProductStockByIdUseCase,
    required this.removeProductStockByIdUseCase,
    required this.getProductStocksByProductIdUseCase,
  });

  final _state = ValueNotifier<ProductStockState>(const ProductStockState());

  ValueListenable<ProductStockState> get state => _state;

  Future<void> addProductStock(ProductStockParam param) async {
    await _run(() => addProductStockUseCase(param));
  }

  Future<void> updateProductStockById(String id, ProductStockParam param) async {
    await _run(() => updateProductStockByIdUseCase(ProductStockUpdateParam(stockId: id, param: param)));
  }

  Future<void> removeProductStockById(String id) async {
    await _run(() => removeProductStockByIdUseCase(id));
  }

  Future<void> getProductStocks(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getProductStocksByProductIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductStock> Function() action) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearCompleted: true);
    try {
      final completed = await action();
      _state.value = _state.value.copyWith(loading: false, completed: completed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCompleted() {
    if (_state.value.completed != null) {
      _state.value = _state.value.copyWith(clearCompleted: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
