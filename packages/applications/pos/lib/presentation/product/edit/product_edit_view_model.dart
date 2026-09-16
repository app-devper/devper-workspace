// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_by_id_use_case.dart';
import 'package:pos/presentation/product/edit/product_edit_state.dart';

class ProductEditViewModel {
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;
  final UpdateProductByIdUseCase updateProductByIdUseCase;
  final RemoveProductByIdUseCase removeProductByIdUseCase;

  ProductEditViewModel({
    required this.getLocalProductByIdUseCase,
    required this.updateProductByIdUseCase,
    required this.removeProductByIdUseCase,
  });

  final _state = ValueNotifier<ProductEditState>(const ProductEditState());
  final _loaded = OneShot<Product>();
  final _updated = OneShot<Product>();
  final _removed = OneShot<Product>();
  final _errors = OneShot<String>();

  ValueListenable<ProductEditState> get state => _state;

  /// The product to fill the form in from.
  Stream<Product> get loaded => _loaded.stream;

  /// The save went through; the panel behind this one reloads.
  Stream<Product> get updated => _updated.stream;

  /// The product was deleted; the screen has nothing left to edit.
  Stream<Product> get removed => _removed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getProductById(String productId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final loaded = await getLocalProductByIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false);
      if (loaded == null) {
        _errors.emit('Product not found');
        return;
      }
      _loaded.emit(loaded);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<void> updateProductById(String productId, ProductParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final updated = await updateProductByIdUseCase(
        ProductUpdateParam(productId: productId, param: param),
      );
      _state.value = _state.value.copyWith(loading: false);
      _updated.emit(updated);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<void> removeProductById(String productId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final removed = await removeProductByIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false);
      _removed.emit(removed);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  void _fail(Exception e) {
    _state.value = _state.value.copyWith(loading: false);
    _errors.emit(toFailure(e).getMessage());
  }

  void dispose() {
    _state.dispose();
    _loaded.dispose();
    _updated.dispose();
    _removed.dispose();
    _errors.dispose();
  }
}
