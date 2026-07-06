// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/price/product_price_state.dart';

class ProductPriceViewModel {
  final ProductRepository productRepo;

  ProductPriceViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductPriceState>();

  Stream<ProductPriceState> get states => _states.stream;

  void addProductPrice(ProductPriceParam param) async {
    _onLoading();
    try {
      final result = await productRepo.addProductPrice(param);
      _onAddProductPrice(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateProductPriceById(String id, ProductPriceParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductPriceById(id, param);
      _onUpdateProductPrice(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeProductPriceById(String id) async {
    _onLoading();
    try {
      final result = await productRepo.removeProductPriceById(id);
      _onRemoveProductPrice(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getProductPrice(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.getProductPricesByProductId(productId);
      _onGetProductPrice(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onAddProductPrice(ProductPrice data) {
    if (!_states.isClosed) {
      _states.sink.add(AddProductPriceState(data: data));
    }
  }

  _onUpdateProductPrice(ProductPrice data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductPriceState(data: data));
    }
  }

  _onRemoveProductPrice(ProductPrice data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveProductPriceState(data: data));
    }
  }

  _onGetProductPrice(List<ProductPrice> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductPricesState(data: data));
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
