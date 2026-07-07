// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';

@immutable
class CartState {
  final List<OrderItem>? orderItems;
  final bool loading;
  final String? error;
  final bool orderSaving;
  final OrderResult? orderResult;
  final String? orderError;

  const CartState({
    this.orderItems,
    this.loading = false,
    this.error,
    this.orderSaving = false,
    this.orderResult,
    this.orderError,
  });

  CartState copyWith({
    List<OrderItem>? orderItems,
    bool? loading,
    String? error,
    bool? orderSaving,
    OrderResult? orderResult,
    String? orderError,
    bool clearError = false,
    bool clearOrderResult = false,
    bool clearOrderError = false,
  }) {
    return CartState(
      orderItems: orderItems ?? this.orderItems,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      orderSaving: orderSaving ?? this.orderSaving,
      orderResult: clearOrderResult ? null : (orderResult ?? this.orderResult),
      orderError: clearOrderError ? null : (orderError ?? this.orderError),
    );
  }
}
