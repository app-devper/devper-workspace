// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'order_ui_model.dart';

abstract class OrderState {}

class LoadingState extends OrderState {}

class InitState extends OrderState {}

class LoggedState extends OrderState {
  final bool isAdmin;

  LoggedState(this.isAdmin);
}

class OrderItemState extends OrderState {
  final List<OrderItem> orderItem;

  OrderItemState(this.orderItem);
}

class OrderRangeState extends OrderState {
  Range range;
  DateTime startDate;
  DateTime endDate;

  OrderRangeState(
    this.range,
    this.startDate,
    this.endDate,
  );
}

class OrderSummaryState extends OrderState {
  final List<OrderSummary> orders;
  final double totalCost;
  final double total;

  OrderSummaryState(
    this.orders,
    this.totalCost,
    this.total,
  );
}

class ErrorState extends OrderState {
  final String message;

  ErrorState(this.message);
}
