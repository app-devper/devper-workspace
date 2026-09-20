// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';

/// What the sales screen renders: the lines of the open sale, what they come
/// to, whether a barcode lookup is running, and whether checkout is in flight.
///
/// The total used to be summed in the page. It is the Sale's answer now, and
/// the screen only draws it.
@immutable
class CartState {
  final List<OrderItem>? orderItems;
  final double total;
  final bool loading;
  final bool orderSaving;

  const CartState({
    this.orderItems,
    this.total = 0,
    this.loading = false,
    this.orderSaving = false,
  });

  CartState copyWith({
    List<OrderItem>? orderItems,
    double? total,
    bool? loading,
    bool? orderSaving,
  }) {
    return CartState(
      orderItems: orderItems ?? this.orderItems,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      orderSaving: orderSaving ?? this.orderSaving,
    );
  }
}
