// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_lot_quantity_by_lot_id_use_case.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_state.dart';

class ProductLotEditViewModel {
  final UpdateProductLotQuantityByLotIdUseCase
      updateProductLotQuantityByLotIdUseCase;
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;

  ProductLotEditViewModel({
    required this.updateProductLotQuantityByLotIdUseCase,
    required this.getLocalProductByIdUseCase,
  });

  final _state =
      ValueNotifier<ProductLotEditState>(const ProductLotEditState());

  ValueListenable<ProductLotEditState> get state => _state;

  void getProductLot(ProductLot lot) {
    _state.value = _state.value.copyWith(task: ProductLotLoaded(lot));
  }

  Future<void> updateProductLot(
      String lotId, UpdateProductLotQuantityParam param) async {
    if (_state.value.task is ProductLotEditRunning) return;
    _state.value = _state.value.copyWith(task: const ProductLotEditRunning());
    try {
      final updated = await updateProductLotQuantityByLotIdUseCase(
        ProductLotQuantityUpdateParam(lotId: lotId, param: param),
      );
      updated.product = await getLocalProductByIdUseCase(updated.productId);
      _state.value = _state.value.copyWith(task: ProductLotUpdated(updated));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductLotEditFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductLotEditFailed) {
      _state.value = _state.value.copyWith(task: const ProductLotEditTask());
    }
  }

  void consumeLoaded() {
    if (_state.value.task is ProductLotLoaded) {
      _state.value = _state.value.copyWith(task: const ProductLotEditTask());
    }
  }

  void consumeUpdated() {
    if (_state.value.task is ProductLotUpdated) {
      _state.value = _state.value.copyWith(task: const ProductLotEditTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
