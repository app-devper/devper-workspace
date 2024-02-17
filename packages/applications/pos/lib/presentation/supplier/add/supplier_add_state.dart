// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class SupplierAddState {}

class LoadingState extends SupplierAddState {}

class CreateSupplierState extends SupplierAddState {
  final Supplier data;

  CreateSupplierState({required this.data});
}

class ErrorState extends SupplierAddState {
  final String message;

  ErrorState({required this.message});
}
