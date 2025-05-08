// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ReceiveAddState {}

class LoadingState extends ReceiveAddState {}

class GetCategoryState extends ReceiveAddState {
  final List<Category> data;

  GetCategoryState({required this.data});
}

class CreateProductState extends ReceiveAddState {
  final Product data;

  CreateProductState({required this.data});
}

class ErrorState extends ReceiveAddState {
  final String message;

  ErrorState({required this.message});
}
