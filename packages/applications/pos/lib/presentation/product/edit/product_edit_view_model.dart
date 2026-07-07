// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/edit/product_edit_state.dart';

class ProductEditViewModel {
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;

  ProductEditViewModel({
    required this.productRepo,
    required this.categoryRepo,
  });

  final _state = ValueNotifier<ProductEditState>(const ProductEditState());

  ValueListenable<ProductEditState> get state => _state;

  Future<void> getProductById(String productId) async {
    try {
      final loaded = await productRepo.getLocalProductById(productId);
      final categories = await categoryRepo.getLocalCategories();
      if (loaded != null) {
        _state.value = _state.value.copyWith(loaded: loaded, categories: categories);
      }
    } on Exception catch (_) {}
  }

  Future<void> updateProductById(String productId, ProductParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await productRepo.updateProductById(productId, param);
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeProductById(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await productRepo.removeProductById(productId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> generateSerialNumber() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearSerialNumber: true);
    try {
      final serialNumber = await productRepo.generateSerialNumber();
      _state.value = _state.value.copyWith(loading: false, serialNumber: serialNumber);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeLoaded() {
    if (_state.value.loaded != null) {
      _state.value = _state.value.copyWith(clearLoaded: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void consumeRemoved() {
    if (_state.value.removed != null) {
      _state.value = _state.value.copyWith(clearRemoved: true);
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
