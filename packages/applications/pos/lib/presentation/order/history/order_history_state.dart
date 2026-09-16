// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';

@immutable
class OrderHistoryState {
  final List<OrderItemDetail> items;
  final bool loading;

  const OrderHistoryState({
    this.items = const [],
    this.loading = false,
  });

  OrderHistoryState copyWith({
    List<OrderItemDetail>? items,
    bool? loading,
  }) {
    return OrderHistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}
