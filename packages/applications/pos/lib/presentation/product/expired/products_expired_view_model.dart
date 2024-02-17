// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/expired/products_expired_state.dart';

class ProductsExpiredViewModel {
  final ProductRepository productRepo;

  ProductsExpiredViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductsExpiredState>();

  Stream<ProductsExpiredState> get states => _states.stream;

  final _lots = StreamController<List<ProductLot>>();

  Stream<List<ProductLot>> get lots => _lots.stream;

  void getProductLotsExpired() async {
    try {
      final result = await productRepo.getProductLotsExpired();
      for (var item in result) {
        item.product = await productRepo.getLocalProductById(item.productId);
      }
      _onListProductLotExpired(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setProductLots(List<ProductLot> data) {
    _lots.sink.add(data);
  }

  void _onLoading() {
    _states.sink.add(LoadingState());
  }

  void _onListProductLotExpired(List<ProductLot> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListExpiresState(
        data: data,
        totalCost: _calculateTotalCost(data),
      ));
    }
  }

  void _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  double _calculateTotalCost(List<ProductLot> data) {
    double total = 0;
    for (var x in data) {
      total += x.costPrice * x.quantity;
    }
    return total;
  }

  void dispose() {
    _states.close();
    _lots.close();
  }
}
