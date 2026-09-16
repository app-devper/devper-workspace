// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item.dart';

/// What the sales screen renders: the lines in the cart, whether a barcode
/// lookup is running, and whether checkout is in flight.
///
/// Both failures and the finished order used to sit here — the order behind a
/// sealed CheckoutState, the lookup failure as a nullable string with a clear
/// flag. None of the three is drawn: two flash a message and one empties the
/// cart. They are on the view model's channels.
@immutable
class CartState {
  final List<OrderItem>? orderItems;
  final bool loading;
  final bool orderSaving;

  const CartState({
    this.orderItems,
    this.loading = false,
    this.orderSaving = false,
  });

  CartState copyWith({
    List<OrderItem>? orderItems,
    bool? loading,
    bool? orderSaving,
  }) {
    return CartState(
      orderItems: orderItems ?? this.orderItems,
      loading: loading ?? this.loading,
      orderSaving: orderSaving ?? this.orderSaving,
    );
  }
}
