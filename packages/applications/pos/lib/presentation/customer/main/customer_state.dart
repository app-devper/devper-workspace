// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

abstract class CustomerState {
}

class LoadingState extends CustomerState {}

class ListCustomerState extends CustomerState {
  final List<Customer> data;

  ListCustomerState({required this.data});
}

class ErrorState extends CustomerState {
  final String message;

  ErrorState({required this.message});
}
