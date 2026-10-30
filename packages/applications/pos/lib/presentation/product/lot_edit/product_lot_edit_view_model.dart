// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_state.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductLotEditViewModel {
  final ProductRepository productRepo;

  ProductLotEditViewModel({
    required this.productRepo,
  });

  final _state =
      ValueNotifier<ProductLotEditState>(const ProductLotEditState());

  /// The lot the form opens with, and the lot it saved. Each reaches the view
  /// once; neither is drawn from state.
  final _loaded = OneShot<ProductLot>();
  final _updated = OneShot<ProductLot>();
  final _errors = OneShot<String>();

  ValueListenable<ProductLotEditState> get state => _state;

  Stream<ProductLot> get loaded => _loaded.stream;

  Stream<ProductLot> get updated => _updated.stream;

  Stream<String> get errors => _errors.stream;

  void getProductLot(ProductLot lot) {
    _loaded.emit(lot);
  }

  Future<void> updateProductLot(
      String lotId, UpdateProductLotQuantityParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final updated =
          await productRepo.updateProductLotQuantityByLotId(lotId, param);
      updated.product =
          await productRepo.getLocalProductById(updated.productId);
      _updated.emit(updated);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _loaded.dispose();
    _updated.dispose();
    _errors.dispose();
  }
}
