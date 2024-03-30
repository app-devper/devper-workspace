// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductStockSequenceState {}

class LoadingState extends ProductStockSequenceState {}

class UpdateProductSequenceState extends ProductStockSequenceState {
  final List<ProductStock> data;

  UpdateProductSequenceState({required this.data});
}

class ErrorState extends ProductStockSequenceState {
  final String message;

  ErrorState({required this.message});
}
