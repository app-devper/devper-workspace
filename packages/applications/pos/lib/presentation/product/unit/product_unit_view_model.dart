// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/add_product_unit_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_unit_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_unit_by_id_use_case.dart';
import 'package:pos/presentation/product/unit/product_unit_state.dart';

class ProductUnitViewModel {
  final AddProductUnitUseCase addProductUnitUseCase;
  final UpdateProductUnitByIdUseCase updateProductUnitByIdUseCase;
  final RemoveProductUnitByIdUseCase removeProductUnitByIdUseCase;
  final GetProductUnitsByProductIdUseCase getProductUnitsByProductIdUseCase;

  ProductUnitViewModel({
    required this.addProductUnitUseCase,
    required this.updateProductUnitByIdUseCase,
    required this.removeProductUnitByIdUseCase,
    required this.getProductUnitsByProductIdUseCase,
  });

  final _state = ValueNotifier<ProductUnitState>(const ProductUnitState());

  /// Delivered once and gone: the sheet closes on it, nothing draws it.
  final _completed = OneShot<ProductUnit>();
  final _errors = OneShot<String>();

  ValueListenable<ProductUnitState> get state => _state;

  Stream<ProductUnit> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> addProductUnit(ProductUnitParam param) async {
    await _run(() => addProductUnitUseCase(param));
  }

  Future<void> updateProductUnitById(String id, ProductUnitParam param) async {
    await _run(() => updateProductUnitByIdUseCase(
        ProductUnitUpdateParam(unitId: id, param: param)));
  }

  Future<void> removeProductUnitById(String id) async {
    await _run(() => removeProductUnitByIdUseCase(id));
  }

  Future<void> getProductUnit(String productId) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await getProductUnitsByProductIdUseCase(productId);
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
