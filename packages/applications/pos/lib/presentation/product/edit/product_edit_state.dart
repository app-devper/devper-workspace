// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductEditState {}

class LoadingState extends ProductEditState {}

class GetProductState extends ProductEditState {
  final Product data;
  final List<Category> categories;

  GetProductState({
    required this.data,
    required this.categories,
  });
}

class UpdateProductState extends ProductEditState {
  final Product data;

  UpdateProductState({required this.data});
}

class RemoveProductState extends ProductEditState {
  final Product data;

  RemoveProductState({required this.data});
}

class GetSerialNumberState extends ProductEditState {
  final String serialNumber;

  GetSerialNumberState({required this.serialNumber});
}

class ErrorState extends ProductEditState {
  final String message;

  ErrorState({required this.message});
}
