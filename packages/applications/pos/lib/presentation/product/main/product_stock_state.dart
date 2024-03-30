// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductStockState {}

class LoadingState extends ProductStockState {}

class GetProductStockState extends ProductStockState {
  final ProductStock data;

  GetProductStockState({required this.data});
}

class AddProductStockState extends ProductStockState {
  final ProductStock data;

  AddProductStockState({required this.data});
}

class UpdateProductStockState extends ProductStockState {
  final ProductStock data;

  UpdateProductStockState({required this.data});
}

class RemoveProductStockState extends ProductStockState {
  final ProductStock data;

  RemoveProductStockState({required this.data});
}

class GetProductStocksState extends ProductStockState {
  final List<ProductStock> data;

  GetProductStocksState({required this.data});
}

class ErrorState extends ProductStockState {
  final String message;

  ErrorState({required this.message});
}
