// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';

/// The mutually exclusive states of checkout.
///
/// Saving, a saved order and a failure are one flow, not three fields: the
/// screen can never be submitting and holding a result at the same time, so
/// the type does not let it.
sealed class CheckoutState {
  const CheckoutState._();
  const factory CheckoutState() = CheckoutIdle;

  // Derived UI projections; no independently writable flags.
  bool get saving => this is CheckoutSubmitting;
  OrderResult? get result => switch (this) {
        CheckoutSucceeded(:final order) => order,
        _ => null,
      };
  String? get error => switch (this) {
        CheckoutFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle() : super._();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting() : super._();
}

final class CheckoutSucceeded extends CheckoutState {
  final OrderResult order;
  const CheckoutSucceeded(this.order) : super._();
}

final class CheckoutFailed extends CheckoutState {
  final Failure failure;
  const CheckoutFailed(this.failure) : super._();
}

@immutable
class CartState {
  final List<OrderItem>? orderItems;

  /// Cart contents and barcode lookup — a separate operation from checkout,
  /// which is why it keeps its own pair rather than joining one progress enum.
  final bool loading;
  final String? error;

  final CheckoutState checkout;

  const CartState({
    this.orderItems,
    this.loading = false,
    this.error,
    this.checkout = const CheckoutIdle(),
  });

  bool get orderSaving => checkout.saving;

  OrderResult? get orderResult => checkout.result;

  String? get orderError => checkout.error;

  CartState copyWith({
    List<OrderItem>? orderItems,
    bool? loading,
    String? error,
    CheckoutState? checkout,
    bool clearError = false,
  }) {
    return CartState(
      orderItems: orderItems ?? this.orderItems,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      checkout: checkout ?? this.checkout,
    );
  }
}
