// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

abstract class CustomerAddState {}

class LoadingState extends CustomerAddState {}

class CreateCustomerState extends CustomerAddState {
  final Customer data;

  CreateCustomerState({required this.data});
}

class ErrorState extends CustomerAddState {
  final String message;

  ErrorState({required this.message});
}
