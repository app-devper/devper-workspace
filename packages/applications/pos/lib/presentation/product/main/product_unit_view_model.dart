// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/main/product_unit_state.dart';

class ProductUnitViewModel {
  final ProductRepository productRepo;

  ProductUnitViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductUnitState>();

  Stream<ProductUnitState> get states => _states.stream;

  void addProductUnit(ProductUnitParam param) async {
    _onLoading();
    try {
      final result = await productRepo.addProductUnit(param);
      _onAddProductUnit(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateProductUnitById(String id, ProductUnitParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductUnitById(id, param);
      _onUpdateProductUnit(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeProductUnitById(String id) async {
    _onLoading();
    try {
      final result = await productRepo.removeProductUnitById(id);
      _onRemoveProductUnit(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getProductUnit(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.getProductUnitsByProductId(productId);
      _onGetProductUnit(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onAddProductUnit(ProductUnit data) {
    if (!_states.isClosed) {
      _states.sink.add(AddProductUnitState(data: data));
    }
  }

  _onUpdateProductUnit(ProductUnit data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductUnitState(data: data));
    }
  }

  _onRemoveProductUnit(ProductUnit data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveProductUnitState(data: data));
    }
  }

  _onGetProductUnit(List<ProductUnit> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductUnitsState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

}
