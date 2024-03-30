// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

abstract class ProductPriceState {}

class LoadingState extends ProductPriceState {}

class AddProductPriceState extends ProductPriceState {
  final ProductPrice data;

  AddProductPriceState({
    required this.data,
  });
}

class UpdateProductPriceState extends ProductPriceState {
  final ProductPrice data;

  UpdateProductPriceState({
    required this.data,
  });
}

class RemoveProductPriceState extends ProductPriceState {
  final ProductPrice data;

  RemoveProductPriceState({
    required this.data,
  });
}

class GetProductPricesState extends ProductPriceState {
  final List<ProductPrice> data;

  GetProductPricesState({
    required this.data,
  });
}

class ErrorState extends ProductPriceState {
  final String message;

  ErrorState({required this.message});
}

