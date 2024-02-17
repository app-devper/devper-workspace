// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class SuppliersState {}

class LoadingState extends SuppliersState {}

class ListSupplierState extends SuppliersState {
  final List<Supplier> data;

  ListSupplierState({required this.data});
}

class ErrorState extends SuppliersState {
  final String message;

  ErrorState({required this.message});
}
