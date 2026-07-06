// Project imports:
import 'package:pos/domain/model/product/product.dart';

abstract class ProductStockQuantityState {}

class LoadingState extends ProductStockQuantityState {}

class UpdateProductStockState extends ProductStockQuantityState {
  final ProductStock data;

  UpdateProductStockState({required this.data});
}

class ErrorState extends ProductStockQuantityState {
  final String message;

  ErrorState({required this.message});
}
