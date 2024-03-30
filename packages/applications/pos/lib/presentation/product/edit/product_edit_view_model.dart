// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/edit/product_edit_state.dart';

class ProductEditViewModel {
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;

  ProductEditViewModel({
    required this.productRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<ProductEditState>();

  Stream<ProductEditState> get states => _states.stream;

  void getProductById(String productId) async {
    try {
      final result = await productRepo.getLocalProductById(productId);
      final categories = await categoryRepo.getLocalCategories();
      _onGetProduct(result!, categories);
    } on Exception catch (e) {}
  }

  void updateProductById(String productId, ProductParam param) async {
    _onLoading();
    try {
      final result = await productRepo.updateProductById(productId, param);
      _onEditProduct(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeProductById(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.removeProductById(productId);
      _onRemoveProduct(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void generateSerialNumber() async {
    _onLoading();
    try {
      final result = await productRepo.generateSerialNumber();
      _onGenerateSerialNumberSuccess(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onRemoveProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveProductState(data: data));
    }
  }

  _onGetProduct(Product data, List<Category> categories) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductState(
        data: data,
        categories: categories,
      ));
    }
  }

  _onEditProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateProductState(data: data));
    }
  }

  _onGenerateSerialNumberSuccess(String serialNumber) {
    if (!_states.isClosed) {
      _states.sink.add(GetSerialNumberState(serialNumber: serialNumber));
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
