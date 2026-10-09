// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/unit/product_unit_state.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductUnitViewModel {
  final ProductRepository productRepo;

  ProductUnitViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductUnitState>(const ProductUnitState());

  /// Delivered once and gone: the sheet closes on it, nothing draws it.
  final _completed = OneShot<ProductUnit>();
  final _errors = OneShot<String>();

  ValueListenable<ProductUnitState> get state => _state;

  Stream<ProductUnit> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

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
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await productRepo.getProductUnitsByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductUnit> Function() action) async {
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
