// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/stock/product_stock_state.dart';

class ProductStockViewModel {
  final ProductRepository productRepo;

  ProductStockViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductStockState>();

  Stream<ProductStockState> get states => _states.stream;

  void addProductStock(ProductStockParam param) async {
    _onLoading();
    try {
      final result = await productRepo.addProductStock(param);
      _onAddProductStock(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateProductStockById(String id, ProductStockParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductStockById(id, param);
      _onUpdateProductStock(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeProductStockById(String id) async {
    _onLoading();
    try {
      final result = await productRepo.removeProductStockById(id);
      _onRemoveProductStock(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getProductStocks(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.getProductStocksByProductId(productId);
      _onGetProductStocks(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onAddProductStock(ProductStock data) {
    if (!_states.isClosed) {
      _states.sink.add(AddProductStockState(data: data));
    }
  }

  _onUpdateProductStock(ProductStock data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductStockState(data: data));
    }
  }

  _onRemoveProductStock(ProductStock data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveProductStockState(data: data));
    }
  }

  _onGetProductStocks(List<ProductStock> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductStocksState(data: data));
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
