// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_state.dart';

class ProductLotEditViewModel {
  final ProductRepository productRepo;

  ProductLotEditViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductLotEditState>(const ProductLotEditState());

  ValueListenable<ProductLotEditState> get state => _state;

  void getProductLot(ProductLot lot) {
    _state.value = _state.value.copyWith(loaded: lot);
  }

  Future<void> updateProductLot(String lotId, UpdateProductLotQuantityParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await productRepo.updateProductLotQuantityByLotId(lotId, param);
      updated.product = await productRepo.getLocalProductById(updated.productId);
      _state.value = _state.value.copyWith(loading: false, updated: updated);
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

  void dispose() {
    _state.dispose();
  }
}
