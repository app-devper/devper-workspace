// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

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

  ValueListenable<ProductUnitState> get state => _state;

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
    _state.value = _state.value.copyWith(task: const ProductUnitRunning());
    try {
      final items = await getProductUnitsByProductIdUseCase(productId);
      _state.value =
          _state.value.copyWith(task: const ProductUnitTask(), items: items);
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductUnitFailed(toFailure(e)));
    }
  }

  Future<void> _run(Future<ProductUnit> Function() action) async {
    _state.value = _state.value.copyWith(task: const ProductUnitRunning());
    try {
      final completed = await action();
      _state.value =
          _state.value.copyWith(task: ProductUnitCompleted(completed));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductUnitFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductUnitFailed) {
      _state.value = _state.value.copyWith(task: const ProductUnitTask());
    }
  }

  void consumeCompleted() {
    if (_state.value.task is ProductUnitCompleted) {
      _state.value = _state.value.copyWith(task: const ProductUnitTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
