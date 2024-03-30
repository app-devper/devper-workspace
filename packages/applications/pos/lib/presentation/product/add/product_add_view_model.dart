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
import 'package:pos/presentation/product/add/product_add_state.dart';

class ProductAddViewModel {
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;

  ProductAddViewModel({
    required this.productRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<ProductAddState>();

  StreamController<ProductAddState> get states => _states;

  void getCategories() async {
    try {
      final result = await categoryRepo.getLocalCategories();
      _onGetCategoriesSuccess(result);
    } on Exception catch (_) {}
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

  void addProduct(CreateProductParam param) async {
    _onLoading();
    try {
      final result = await productRepo.addProduct(param);
      await productRepo.getProductUnitsByProductId(result.id);
      await productRepo.getProductPricesByProductId(result.id);
      _onCreateProduct(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    if (!_states.isClosed) {
      _states.sink.add(LoadingState());
    }
  }

  _onCreateProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(CreateProductState(data: data));
    }
  }

  _onGenerateSerialNumberSuccess(String serialNumber) {
    if (!_states.isClosed) {
      _states.sink.add(GetSerialNumberState(serialNumber: serialNumber));
    }
  }

  _onGetCategoriesSuccess(List<Category> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetCategoryState(data: data));
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
