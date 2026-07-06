// Project imports:
import 'package:pos/domain/model/product/product_history.dart';

abstract class ProductHistoryState {}

class LoadingState extends ProductHistoryState {}

class ListHistoryState extends ProductHistoryState {
  final List<ProductHistory> data;

  ListHistoryState({required this.data});
}

class ErrorState extends ProductHistoryState {
  final String message;

  ErrorState({required this.message});
}
