// Project imports:
import 'package:pos/domain/model/product/product.dart';

abstract class ProductState {}

class InitState extends ProductState {}

class ProductInfoState extends ProductState {
  final Product data;

  ProductInfoState({
    required this.data,
  });
}

class ErrorState extends ProductState {
  final String message;

  ErrorState({required this.message});
}
