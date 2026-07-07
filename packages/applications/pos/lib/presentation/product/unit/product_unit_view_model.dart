// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/unit/product_unit_state.dart';

class ProductUnitViewModel {
  final ProductRepository productRepo;

  ProductUnitViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductUnitState>(const ProductUnitState());

  ValueListenable<ProductUnitState> get state => _state;

  Future<void> addProductUnit(ProductUnitParam param) async {
    await _run(() => productRepo.addProductUnit(param));
  }

  Future<void> updateProductUnitById(String id, ProductUnitParam param) async {
    await _run(() => productRepo.updateProductUnitById(id, param));
  }

  Future<void> removeProductUnitById(String id) async {
    await _run(() => productRepo.removeProductUnitById(id));
  }

  Future<void> getProductUnit(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await productRepo.getProductUnitsByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductUnit> Function() action) async {
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
