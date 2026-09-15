// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

// Project imports:
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/usecase/order/get_order_range_use_case.dart';
import 'order_state.dart';
import 'order_ui_model.dart';

class OrderViewModel {
  final GetOrderRangeUseCase getOrderRangeUseCase;
  final GetRoleUseCase getRoleUseCase;

  OrderViewModel({
    required this.getRoleUseCase,
    required this.getOrderRangeUseCase,
  });

  final _state = ValueNotifier<OrderState>(const OrderState());

  /// Picking a range tells the page to move its date fields and reload; a
  /// failure flashes a message. Neither is drawn.
  final _rangeSelections = OneShot<OrderRangeSelection>();
  final _errors = OneShot<String>();

  ValueListenable<OrderState> get state => _state;

  Stream<OrderRangeSelection> get rangeSelections => _rangeSelections.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getOrderItem(String type, GetOrderRangeParam param) async {
    try {
      final result = await getOrderRangeUseCase(param);
      final orders = _filterOrders(type, result);
      double total = 0;
      double totalCost = 0;
      for (var x in orders) {
        total += x.total;
        totalCost += x.totalCost;
      }
      _state.value = _state.value
          .copyWith(orders: orders, total: total, totalCost: totalCost);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> checkLogin() async {
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(isAdmin: role == "ADMIN");
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  void initData() {
    final ranges = [
      ListItem(Range.today, "Today"),
      ListItem(Range.yesterday, "Yesterday"),
      ListItem(Range.date, "Date"),
      ListItem(Range.dateRange, "Date Range"),
      ListItem(Range.currentMonth, "Current Month"),
      ListItem(Range.lastMonth, "Last Month"),
    ];
    _state.value = _state.value.copyWith(ranges: ranges);
  }

  void selectRange(Range range) {
    final now = DateTime.now();
    OrderRangeSelection? selection;
    switch (range) {
      case Range.today:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, now.day),
          endDate: DateTime(now.year, now.month, now.day + 1),
        );
        break;
      case Range.yesterday:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1)),
          endDate: DateTime(now.year, now.month, now.day),
        );
        break;
      case Range.last7Days:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 8)),
          endDate: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1)),
        );
        break;
      case Range.last30Days:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 31)),
          endDate: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1)),
        );
        break;
      case Range.currentMonth:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 1),
        );
        break;
      case Range.lastMonth:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month - 1, 1),
          endDate: DateTime(now.year, now.month, 1),
        );
        break;
      case Range.dateRange:
        selection =
            OrderRangeSelection(range: range, startDate: now, endDate: now);
        break;
      case Range.date:
        selection = OrderRangeSelection(
          range: range,
          startDate: DateTime(now.year, now.month, now.day),
          endDate: DateTime(now.year, now.month, now.day + 1),
        );
        break;
      case Range.month:
        break;
    }
    if (selection != null) {
      _rangeSelections.emit(selection);
    }
  }

  void dispose() {
    _state.dispose();
    _rangeSelections.dispose();
    _errors.dispose();
  }

  List<OrderSummary> _filterOrders(String type, List<OrderSummary> data) {
    if (type == "Store") {
      return data.where((item) {
        return item.type == "Cash" || item.type.isEmpty;
      }).toList();
    } else if (type == "Online") {
      return data.where((item) {
        return item.type == "Online";
      }).toList();
    } else {
      return data;
    }
  }
}
