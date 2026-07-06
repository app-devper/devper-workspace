// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

abstract class CustomerState {
}

class LoadingState extends CustomerState {}

class GetCustomerState extends CustomerState {
  final Customer data;

  GetCustomerState({required this.data});
}

class ErrorState extends CustomerState {
  final String message;

  ErrorState({required this.message});
}
