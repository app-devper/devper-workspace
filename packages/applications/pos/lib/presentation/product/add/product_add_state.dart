// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductAddState {}

class LoadingState extends ProductAddState {}

class GetProductState extends ProductAddState {
  final Product? data;

  GetProductState({required this.data});
}

class GetCategoryState extends ProductAddState {
  final List<Category> data;

  GetCategoryState({required this.data});
}

class CreateProductState extends ProductAddState {
  final Product data;

  CreateProductState({required this.data});
}

class GetSerialNumberState extends ProductAddState {
  final String serialNumber;

  GetSerialNumberState({required this.serialNumber});
}

class ErrorState extends ProductAddState {
  final String message;

  ErrorState({required this.message});
}
