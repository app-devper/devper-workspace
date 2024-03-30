// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/main/product_stock_quantity_state.dart';

class ProductStockQuantityViewModel {
  final ProductRepository productRepo;

  ProductStockQuantityViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductStockQuantityState>();

  Stream<ProductStockQuantityState> get states => _states.stream;

  void updateProductStockQuantityById(String id, UpdateProductStockQuantityParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductStockQuantityById(id, param);
      _onUpdateProductStock(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    if (!_states.isClosed) {
      _states.sink.add(LoadingState());
    }
  }

  _onUpdateProductStock(ProductStock data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductStockState(data: data));
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
