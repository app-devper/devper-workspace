// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/stock/product_stock_state.dart';

class ProductStockViewModel {
  final ProductRepository productRepo;

  ProductStockViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductStockState>(const ProductStockState());

  ValueListenable<ProductStockState> get state => _state;

  Future<void> addProductStock(ProductStockParam param) async {
    await _run(() => productRepo.addProductStock(param));
  }

  Future<void> updateProductStockById(String id, ProductStockParam param) async {
    await _run(() => productRepo.updateProductStockById(id, param));
  }

  Future<void> removeProductStockById(String id) async {
    await _run(() => productRepo.removeProductStockById(id));
  }

  Future<void> getProductStocks(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await productRepo.getProductStocksByProductId(productId);
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
