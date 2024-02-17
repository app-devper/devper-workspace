// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';

abstract class ProductLotEditState {}

class LoadingState extends ProductLotEditState {}

class GetProductLotState extends ProductLotEditState {
  final ProductLot data;

  GetProductLotState({required this.data});
}

class UpdateProductLotState extends ProductLotEditState {
  final ProductLot data;

  UpdateProductLotState({required this.data});
}

class ErrorState extends ProductLotEditState {
  final String message;

  ErrorState({required this.message});
}
