// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';

abstract class HomeState {}

class LoadingState extends HomeState {}

class CheckRoleState extends HomeState {
  final bool isAdmin;

  CheckRoleState(this.isAdmin);
}

class OrderItemState extends HomeState {
  final List<OrderItem> orderItems;

  OrderItemState(this.orderItems);
}

class OrderLoadingState extends HomeState {}

class OrderResultState extends HomeState {
  final OrderResult order;

  OrderResultState(this.order);
}

class OrderErrorState extends HomeState {
  final String message;

  OrderErrorState(this.message);
}

class CustomersState extends HomeState {
  final List<Customer> customers;

  CustomersState(this.customers);
}

class ErrorState extends HomeState {
  final String message;

  ErrorState(this.message);
}

class LogoutState extends HomeState {}
