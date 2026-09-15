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

/// What this screen renders: the range options, the orders in the chosen
/// range, their totals, and whether the user is an admin.
///
/// It also carried three signals — the role answer, an "initialised" flag and
/// the chosen range — which the page consumed in turn to drive the next step.
/// Those are events, and the sequence they were standing in for is now just
/// three calls in initState.
@immutable
class OrderState {
  final List<ListItem> ranges;
  final List<OrderSummary>? orders;
  final double totalCost;
  final double total;
  final bool isAdmin;

  const OrderState({
    this.ranges = const [],
    this.orders,
    this.totalCost = 0,
    this.total = 0,
    this.isAdmin = false,
  });

  OrderState copyWith({
    List<ListItem>? ranges,
    List<OrderSummary>? orders,
    double? totalCost,
    double? total,
    bool? isAdmin,
  }) {
    return OrderState(
      ranges: ranges ?? this.ranges,
      orders: orders ?? this.orders,
      totalCost: totalCost ?? this.totalCost,
      total: total ?? this.total,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
