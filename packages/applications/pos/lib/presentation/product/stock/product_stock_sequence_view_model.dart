// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_state.dart';

class ProductStockSequenceViewModel {
  final ProductRepository productRepo;

  ProductStockSequenceViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductStockSequenceState>();

  Stream<ProductStockSequenceState> get states => _states.stream;

  void updateProductStockSequenceById(UpdateProductStockSequenceParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductStockSequence(param);
      _onUpdateProductSequence(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onUpdateProductSequence(List<ProductStock> data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductSequenceState(data: data));
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
