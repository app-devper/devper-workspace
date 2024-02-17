// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class SupplierEditState {}

class LoadingState extends SupplierEditState {}

class GetSupplierState extends SupplierEditState {
  final Supplier data;

  GetSupplierState({required this.data});
}

class UpdateSupplierState extends SupplierEditState {
  final Supplier data;

  UpdateSupplierState({required this.data});
}

class RemoveSupplierState extends SupplierEditState {
  final Supplier data;

  RemoveSupplierState({required this.data});
}

class ErrorState extends SupplierEditState {
  final String message;

  ErrorState({required this.message});
}
