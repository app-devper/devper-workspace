// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';

abstract class OrderHistoryState {}

class LoadingState extends OrderHistoryState {}

class OrderItemState extends OrderHistoryState {
  final List<OrderItemDetail> items;

  OrderItemState(this.items);
}

class ErrorState extends OrderHistoryState {
  final String message;

  ErrorState(this.message);
}
