// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'order_state.dart';
import 'order_ui_model.dart';

class OrderViewModel {
  final OrderRepository orderRepo;
  final LoginRepository loginRepo;

  OrderViewModel({
    required this.loginRepo,
    required this.orderRepo,
  });

  final _states = StreamController<OrderState>();

  StreamController<OrderState> get states => _states;

  final _orders = StreamController<List<OrderSummary>>();

  StreamController<List<OrderSummary>> get orders => _orders;

  final _dropdownItems = StreamController<List<ListItem>>();

  StreamController<List<ListItem>> get dropdownItem => _dropdownItems;

  void getOrderItem(String type, GetOrderRangeParam param) async {
    try {
      final result = await orderRepo.getOrderRange(param);
      _onOrderSummary(type, result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void checkLogin() async {
    try {
      final result = await loginRepo.getRole();
      _onCheckLogin(result == "ADMIN");
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void initData() {
    List<ListItem> dropdownItems = [
      ListItem(Range.Today, "Today"),
      ListItem(Range.Yesterday, "Yesterday"),
      ListItem(Range.Date, "Date"),
      ListItem(Range.DateRange, "Date Range"),
      ListItem(Range.CurrentMonth, "Current Month"),
      ListItem(Range.LastMonth, "Last Month"),
    ];
    _dropdownItems.sink.add(dropdownItems);
    _states.sink.add((InitState()));
  }

  void selectRange(Range range) {
    final now = DateTime.now();
    switch (range) {
      case Range.Today:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, now.day);
          DateTime endDate = DateTime(now.year, now.month, now.day + 1);
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.Yesterday:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          DateTime endDate = DateTime(now.year, now.month, now.day);
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.Last7Days:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 8));
          DateTime endDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.Last30Days:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 31));
          DateTime endDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.CurrentMonth:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, 1);
          DateTime endDate = DateTime(now.year, now.month + 1, 1);
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.LastMonth:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month - 1, 1);
          DateTime endDate = DateTime(now.year, now.month, 1);
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.DateRange:
        if (!_states.isClosed) {
          _states.sink.add((OrderRangeState(range, now, now)));
        }
        break;
      case Range.Date:
        if (!_states.isClosed) {
          DateTime startDate = DateTime(now.year, now.month, now.day);
          DateTime endDate = DateTime(now.year, now.month, now.day + 1);
          _states.sink.add((OrderRangeState(range, startDate, endDate)));
        }
        break;
      case Range.Month:
        break;
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCheckLogin(bool isLogin) {
    if (!_states.isClosed) {
      _states.sink.add((LoggedState(isLogin)));
    }
  }

  _onOrderSummary(String type, List<OrderSummary> result) {
    if (!_states.isClosed) {
      final orders = _filterOrders(type, result);
      double total = 0;
      double totalCost = 0;
      for (var x in orders) {
        total += x.total;
        totalCost += x.totalCost;
      }
      _orders.sink.add(orders);
      _states.sink.add(OrderSummaryState(
        orders,
        totalCost,
        total,
      ));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.getMessage()));
    }
  }

  dispose() {
    _dropdownItems.close();
    _states.close();
    _orders.close();
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
