// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/usecase/auth/get_role_use_case.dart';

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

  ValueListenable<OrderState> get state => _state;

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
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> checkLogin() async {
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(logged: role == "ADMIN");
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
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
    _state.value = _state.value.copyWith(ranges: ranges, initialized: true);
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
      _state.value = _state.value.copyWith(rangeSelection: selection);
    }
  }

  void consumeLogged() {
    if (_state.value.logged != null) {
      _state.value = _state.value.copyWith(clearLogged: true);
    }
  }

  void consumeInitialized() {
    if (_state.value.initialized) {
      _state.value = _state.value.copyWith(clearInitialized: true);
    }
  }

  void consumeRangeSelection() {
    if (_state.value.rangeSelection != null) {
      _state.value = _state.value.copyWith(clearRangeSelection: true);
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
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
