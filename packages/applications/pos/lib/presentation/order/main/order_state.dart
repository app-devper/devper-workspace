// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/order/order_summary.dart';
import 'order_ui_model.dart';

@immutable
class OrderRangeSelection {
  final Range range;
  final DateTime startDate;
  final DateTime endDate;

  const OrderRangeSelection({
    required this.range,
    required this.startDate,
    required this.endDate,
  });
}

@immutable
class OrderState {
  final List<ListItem> ranges;
  final List<OrderSummary>? orders;
  final double totalCost;
  final double total;
  final bool? logged;
  final bool initialized;
  final OrderRangeSelection? rangeSelection;
  final String? error;

  const OrderState({
    this.ranges = const [],
    this.orders,
    this.totalCost = 0,
    this.total = 0,
    this.logged,
    this.initialized = false,
    this.rangeSelection,
    this.error,
  });

  OrderState copyWith({
    List<ListItem>? ranges,
    List<OrderSummary>? orders,
    double? totalCost,
    double? total,
    bool? logged,
    bool? initialized,
    OrderRangeSelection? rangeSelection,
    String? error,
    bool clearLogged = false,
    bool clearInitialized = false,
    bool clearRangeSelection = false,
    bool clearError = false,
  }) {
    return OrderState(
      ranges: ranges ?? this.ranges,
      orders: orders ?? this.orders,
      totalCost: totalCost ?? this.totalCost,
      total: total ?? this.total,
      logged: clearLogged ? null : (logged ?? this.logged),
      initialized: clearInitialized ? false : (initialized ?? this.initialized),
      rangeSelection: clearRangeSelection ? null : (rangeSelection ?? this.rangeSelection),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
