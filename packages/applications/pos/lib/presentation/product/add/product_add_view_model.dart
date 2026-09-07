// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/category/get_local_categories_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_use_case.dart';
import 'package:pos/domain/usecase/product/generate_serial_number_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/presentation/product/add/product_add_state.dart';

class ProductAddViewModel {
  final GetLocalCategoriesUseCase getLocalCategoriesUseCase;
  final GenerateSerialNumberUseCase generateSerialNumberUseCase;
  final AddProductUseCase addProductUseCase;
  final GetProductUnitsByProductIdUseCase getProductUnitsByProductIdUseCase;
  final GetProductPricesByProductIdUseCase getProductPricesByProductIdUseCase;

  ProductAddViewModel({
    required this.getLocalCategoriesUseCase,
    required this.generateSerialNumberUseCase,
    required this.addProductUseCase,
    required this.getProductUnitsByProductIdUseCase,
    required this.getProductPricesByProductIdUseCase,
  });

  final _state = ValueNotifier<ProductAddState>(const ProductAddState());

  ValueListenable<ProductAddState> get state => _state;

  Future<void> getCategories() async {
    try {
      final categories = await getLocalCategoriesUseCase();
      _state.value = _state.value.copyWith(categories: categories);
    } on Exception catch (_) {}
  }

  Future<void> generateSerialNumber() async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearSerialNumber: true);
    try {
      final serialNumber = await generateSerialNumberUseCase();
      _state.value = _state.value.copyWith(saving: false, serialNumber: serialNumber);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> addProduct(CreateProductParam param) async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearCreated: true);
    try {
      final created = await addProductUseCase(param);
      await getProductUnitsByProductIdUseCase(created.id);
      await getProductPricesByProductIdUseCase(created.id);
      _state.value = _state.value.copyWith(saving: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void consumeSerialNumber() {
    if (_state.value.serialNumber != null) {
      _state.value = _state.value.copyWith(clearSerialNumber: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
