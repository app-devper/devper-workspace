// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/category/get_local_categories_use_case.dart';
import 'package:pos/domain/usecase/product/generate_serial_number_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_by_id_use_case.dart';
import 'package:pos/presentation/product/edit/product_edit_state.dart';

class ProductEditViewModel {
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;
  final GetLocalCategoriesUseCase getLocalCategoriesUseCase;
  final UpdateProductByIdUseCase updateProductByIdUseCase;
  final RemoveProductByIdUseCase removeProductByIdUseCase;
  final GenerateSerialNumberUseCase generateSerialNumberUseCase;

  ProductEditViewModel({
    required this.getLocalProductByIdUseCase,
    required this.getLocalCategoriesUseCase,
    required this.updateProductByIdUseCase,
    required this.removeProductByIdUseCase,
    required this.generateSerialNumberUseCase,
  });

  final _state = ValueNotifier<ProductEditState>(const ProductEditState());

  ValueListenable<ProductEditState> get state => _state;

  Future<void> getProductById(String productId) async {
    if (_state.value.task is ProductEditRunning) return;
    _state.value = _state.value.copyWith(task: const ProductEditRunning());
    try {
      final loaded = await getLocalProductByIdUseCase(productId);
      final categories = await getLocalCategoriesUseCase();
      if (loaded != null) {
        _state.value = _state.value.copyWith(
          task: ProductLoaded(loaded),
          categories: categories,
        );
      } else {
        _state.value = _state.value.copyWith(task: const ProductMissing());
      }
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductEditFailed(toFailure(e)));
    }
  }

  Future<void> updateProductById(String productId, ProductParam param) async {
    if (_state.value.task is ProductEditRunning) return;
    _state.value = _state.value.copyWith(task: const ProductEditRunning());
    try {
      final updated = await updateProductByIdUseCase(
        ProductUpdateParam(productId: productId, param: param),
      );
      _state.value = _state.value.copyWith(task: ProductUpdated(updated));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductEditFailed(toFailure(e)));
    }
  }

  Future<void> removeProductById(String productId) async {
    if (_state.value.task is ProductEditRunning) return;
    _state.value = _state.value.copyWith(task: const ProductEditRunning());
    try {
      final removed = await removeProductByIdUseCase(productId);
      _state.value = _state.value.copyWith(task: ProductRemoved(removed));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductEditFailed(toFailure(e)));
    }
  }

  Future<void> generateSerialNumber() async {
    if (_state.value.task is ProductEditRunning) return;
    _state.value = _state.value.copyWith(task: const ProductEditRunning());
    try {
      final serialNumber = await generateSerialNumberUseCase();
      _state.value =
          _state.value.copyWith(task: SerialNumberReady(serialNumber));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductEditFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductEditFailed ||
        _state.value.task is ProductMissing) {
      _state.value = _state.value.copyWith(task: const ProductEditTask());
    }
  }

  void consumeLoaded() {
    if (_state.value.task is ProductLoaded) {
      _state.value = _state.value.copyWith(task: const ProductEditTask());
    }
  }

  void consumeUpdated() {
    if (_state.value.task is ProductUpdated) {
      _state.value = _state.value.copyWith(task: const ProductEditTask());
    }
  }

  void consumeRemoved() {
    if (_state.value.task is ProductRemoved) {
      _state.value = _state.value.copyWith(task: const ProductEditTask());
    }
  }

  void consumeSerialNumber() {
    if (_state.value.task is SerialNumberReady) {
      _state.value = _state.value.copyWith(task: const ProductEditTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
