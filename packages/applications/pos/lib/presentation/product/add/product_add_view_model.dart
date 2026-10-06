// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/product/add_product_use_case.dart';
import 'package:pos/domain/usecase/product/generate_serial_number_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/presentation/product/add/product_add_state.dart';

import 'package:pos/domain/repositories/category_repository.dart';

class ProductAddViewModel {
  final CategoryRepository categoryRepo;
  final GenerateSerialNumberUseCase generateSerialNumberUseCase;
  final AddProductUseCase addProductUseCase;
  final GetProductUnitsByProductIdUseCase getProductUnitsByProductIdUseCase;
  final GetProductPricesByProductIdUseCase getProductPricesByProductIdUseCase;

  ProductAddViewModel({
    required this.categoryRepo,
    required this.generateSerialNumberUseCase,
    required this.addProductUseCase,
    required this.getProductUnitsByProductIdUseCase,
    required this.getProductPricesByProductIdUseCase,
  });

  final _state = ValueNotifier<ProductAddState>(const ProductAddState());

  /// The product it created and the serial number it generated. Each is acted
  /// on once and never drawn.
  final _created = OneShot<Product>();
  final _serialNumbers = OneShot<String>();
  final _errors = OneShot<String>();

  ValueListenable<ProductAddState> get state => _state;

  Stream<Product> get created => _created.stream;

  Stream<String> get serialNumbers => _serialNumbers.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getCategories() async {
    try {
      final categories = await categoryRepo.getLocalCategories();
      _state.value = _state.value.copyWith(categories: categories);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> generateSerialNumber() async {
    if (_state.value.saving) return;
    _state.value = _state.value.copyWith(saving: true);
    try {
      _serialNumbers.emit(await generateSerialNumberUseCase());
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }

  Future<void> addProduct(CreateProductParam param) async {
    if (_state.value.saving) return;
    _state.value = _state.value.copyWith(saving: true);
    try {
      final created = await addProductUseCase(param);
      await getProductUnitsByProductIdUseCase(created.id);
      await getProductPricesByProductIdUseCase(created.id);
      _created.emit(created);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _serialNumbers.dispose();
    _errors.dispose();
  }
}
