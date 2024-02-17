// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductsState {}

class LoadingState extends ProductsState {}

class LoggedState extends ProductsState {
  final bool isAdmin;

  LoggedState(this.isAdmin);
}

class ListProductsState extends ProductsState {
  final List<Product> data;

  ListProductsState({required this.data});
}

class ProductsResultState extends ProductsState {
  final List<Product> data;
  final double totalCost;

  ProductsResultState({required this.data, required this.totalCost});
}

class RemoveProductState extends ProductsState {
  final Product data;

  RemoveProductState({required this.data});
}

class ErrorState extends ProductsState {
  final String message;

  ErrorState({required this.message});
}

class GetCategoryState extends ProductsState {
  final List<Category> data;

  GetCategoryState({required this.data});
}

