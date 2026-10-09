// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/stock/product_stock_state.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductStockViewModel {
  final ProductRepository productRepo;

  ProductStockViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductStockState>(const ProductStockState());

  /// Delivered once and gone: the sheet closes on it, nothing draws it.
  final _completed = OneShot<ProductStock>();
  final _errors = OneShot<String>();

  ValueListenable<ProductStockState> get state => _state;

  Stream<ProductStock> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> addProductStock(ProductStockParam param) async {
    await _run(() => productRepo.addProductStock(param));
  }

  Future<void> updateProductStockById(
      String id, ProductStockParam param) async {
    await _run(() => productRepo.updateProductStockById(id, param));
  }

  Future<void> removeProductStockById(String id) async {
    await _run(() => productRepo.removeProductStockById(id));
  }

  Future<void> getProductStocks(String productId) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await productRepo.getProductStocksByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductStock> Function() action) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      _completed.emit(await action());
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _completed.dispose();
    _errors.dispose();
  }
}
