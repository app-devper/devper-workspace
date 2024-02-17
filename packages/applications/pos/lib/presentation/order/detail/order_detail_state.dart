// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class OrderDetailState {}

class LoadingState extends OrderDetailState {}

class UpdateTotalCostState extends OrderDetailState {}

class LoggedState extends OrderDetailState {
  final bool isAdmin;

  LoggedState(this.isAdmin);
}

class OrderState extends OrderDetailState {
  final OrderDetail order;

  OrderState(this.order);
}

class RemoveOrderState extends OrderDetailState {
  final OrderDetail order;

  RemoveOrderState(this.order);
}

class RemoveOrderItemState extends OrderDetailState {
  final OrderItemDetail item;

  RemoveOrderItemState(this.item);
}

class CustomersState extends OrderDetailState {
  final List<Customer> customers;

  CustomersState(this.customers);
}

class GetSupplierState extends OrderDetailState {
  final Supplier supplier;

  final Customer? customer;

  GetSupplierState({
    required this.supplier,
    required this.customer,
  });
}

class GetSupplierErrorState extends OrderDetailState {
  final String message;

  GetSupplierErrorState(this.message);
}

class ErrorState extends OrderDetailState {
  final String message;

  ErrorState(this.message);
}
