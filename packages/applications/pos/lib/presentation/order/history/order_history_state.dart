// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';

@immutable
class OrderHistoryState {
  final List<OrderItemDetail> items;
  final bool loading;
  final String? error;

  const OrderHistoryState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  OrderHistoryState copyWith({
    List<OrderItemDetail>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return OrderHistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
