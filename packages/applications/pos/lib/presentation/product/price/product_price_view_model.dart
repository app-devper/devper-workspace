// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/price/product_price_state.dart';

class ProductPriceViewModel {
  final ProductRepository productRepo;

  ProductPriceViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductPriceState>(const ProductPriceState());

  ValueListenable<ProductPriceState> get state => _state;

  Future<void> addProductPrice(ProductPriceParam param) async {
    await _run(() => productRepo.addProductPrice(param));
  }

  Future<void> updateProductPriceById(String id, ProductPriceParam param) async {
    await _run(() => productRepo.updateProductPriceById(id, param));
  }

  Future<void> removeProductPriceById(String id) async {
    await _run(() => productRepo.removeProductPriceById(id));
  }

  Future<void> getProductPrice(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await productRepo.getProductPricesByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductPrice> Function() action) async {
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
