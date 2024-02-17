// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';

abstract class ProductsExpiredState {}

class LoadingState extends ProductsExpiredState {}

class ListExpiresState extends ProductsExpiredState {
  final List<ProductLot> data;
  final double totalCost;

  ListExpiresState({
    required this.data,
    required this.totalCost,
  });
}

class ErrorState extends ProductsExpiredState {
  final String message;

  ErrorState({required this.message});
}
