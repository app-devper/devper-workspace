// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductUnitState {}

class LoadingState extends ProductUnitState {}

class GetProductUnitsState extends ProductUnitState {
  final List<ProductUnit> data;

  GetProductUnitsState({
    required this.data,
  });
}

class AddProductUnitState extends ProductUnitState {
  final ProductUnit data;

  AddProductUnitState({
    required this.data,
  });
}

class UpdateProductUnitState extends ProductUnitState {
  final ProductUnit data;

  UpdateProductUnitState({
    required this.data,
  });
}

class RemoveProductUnitState extends ProductUnitState {
  final ProductUnit data;

  RemoveProductUnitState({
    required this.data,
  });
}

class ErrorState extends ProductUnitState {
  final String message;

  ErrorState({required this.message});
}
