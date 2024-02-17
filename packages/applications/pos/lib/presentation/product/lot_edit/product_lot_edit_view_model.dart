// Dart imports:
import 'dart:async';

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

  final _states = StreamController<ProductLotEditState>();

  Stream<ProductLotEditState> get states => _states.stream;

  void getProductLot(ProductLot lot) async {
    try {
      _onGetProductLot(lot);
    } on Exception catch (_) {
    }
  }

  void updateProductLot(String lotId, UpdateProductLotQuantityParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductLotQuantityByLotId(lotId, param);
      result.product = await productRepo.getLocalProductById(result.productId);
      _onUpdateProductLot(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onGetProductLot(ProductLot data) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductLotState(data: data));
    }
  }

  _onUpdateProductLot(ProductLot data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductLotState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
