// Project imports:
import 'package:pos/domain/model/product/product.dart';

abstract class ScannerState {}

class LoadingState extends ScannerState {}

class GetProductState extends ScannerState {
  final Product data;

  GetProductState({required this.data});
}

class ErrorState extends ScannerState {
  final String message;

  ErrorState({required this.message});
}
