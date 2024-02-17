// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

abstract class CustomerEditState {}

class LoadingState extends CustomerEditState {}

class GetCustomerState extends CustomerEditState {
  final Customer data;

  GetCustomerState({required this.data});
}

class UpdateCustomerState extends CustomerEditState {
  final Customer data;

  UpdateCustomerState({required this.data});
}

class RemoveCustomerState extends CustomerEditState {
  final Customer data;

  RemoveCustomerState({required this.data});
}

class ErrorState extends CustomerEditState {
  final String message;

  ErrorState({required this.message});
}
