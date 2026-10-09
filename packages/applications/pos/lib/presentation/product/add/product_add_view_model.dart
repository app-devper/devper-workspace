// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/presentation/product/add/product_add_state.dart';

import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductAddViewModel {
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;

  ProductAddViewModel({
    required this.productRepo,
    required this.categoryRepo,
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
      _serialNumbers.emit(await productRepo.generateSerialNumber());
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
      // The catalogue reads the new Product with its Unit and Price itself. A
      // follow-up read here used to fail after the Product was created, and
      // a retry made a second one.
      _created.emit(await productRepo.addProduct(param));
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
