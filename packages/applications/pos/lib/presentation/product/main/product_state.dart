// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';

abstract class ProductState {}

class InitState extends ProductState {}

class LoadingState extends ProductState {}

class ProductInfoState extends ProductState {
  final Product data;

  ProductInfoState({
    required this.data,
  });
}

class ImportCSVState extends ProductState {
  final CSVImportResult data;

  ImportCSVState({required this.data});
}

class ClearSoldFirstState extends ProductState {
  final Product data;

  ClearSoldFirstState({required this.data});
}

class ErrorState extends ProductState {
  final String message;

  ErrorState({required this.message});
}
