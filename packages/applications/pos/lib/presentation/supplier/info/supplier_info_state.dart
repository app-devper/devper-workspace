// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class SupplierInfoState {}

class LoadingState extends SupplierInfoState {}

class GetSupplierState extends SupplierInfoState {
  final Supplier data;

  GetSupplierState({required this.data});
}

class UpdateSupplierState extends SupplierInfoState {
  final Supplier data;

  UpdateSupplierState({required this.data});
}

class ErrorState extends SupplierInfoState {
  final String message;

  ErrorState({required this.message});
}
