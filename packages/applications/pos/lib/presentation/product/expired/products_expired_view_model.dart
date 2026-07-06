// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/expired/products_expire_ui_model.dart';
import 'package:pos/presentation/product/expired/products_expired_state.dart';

class ProductsExpiredViewModel {
  final ProductRepository productRepo;

  ProductsExpiredViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductsExpiredState>();

  Stream<ProductsExpiredState> get states => _states.stream;

  final _lots = StreamController<List<ProductLot>>();

  Stream<List<ProductLot>> get lots => _lots.stream;

  final _dropdownItems = StreamController<List<ListItem>>();

  StreamController<List<ListItem>> get dropdownItem => _dropdownItems;

  late DateTime _startDate;
  late DateTime _endDate;

  void initData() {
    final dropdownItems = [
      ListItem(Range.expired90Day, "หมดอายุแล้ว90วัน"),
      ListItem(Range.expired60Day, "หมดอายุแล้ว60วัน"),
      ListItem(Range.expired30Day, "หมดอายุแล้ว30วัน"),
      ListItem(Range.today, "หมดอายุวันนี้"),
      ListItem(Range.before30Days, "ใกล้หมดอายุ30วัน"),
      ListItem(Range.before60Days, "ใกล้หมดอายุ60วัน"),
      ListItem(Range.before90Days, "ใกล้หมดอายุ90วัน"),
      ListItem(Range.before180Days, "ใกล้หมดอายุ180วัน"),
      ListItem(Range.before240Days, "ใกล้หมดอายุ240วัน"),
    ];
    _dropdownItems.sink.add(dropdownItems);
  }

  void selectRange(Range range) {
    final now = DateTime.now();
    switch (range) {
      case Range.expired90Day:
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 90));
        _endDate = DateTime(now.year, now.month, now.day);
        break;
      case Range.expired60Day:
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 60));
        _endDate = DateTime(now.year, now.month, now.day);
        break;
      case Range.expired30Day:
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
        _endDate = DateTime(now.year, now.month, now.day);
        break;
      case Range.today:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day + 1);
        break;
      case Range.before30Days:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 31));
        break;
      case Range.before60Days:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 61));
        break;
      case Range.before90Days:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 91));
        break;
      case Range.before180Days:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 181));
        break;
      case Range.before240Days:
        _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        _endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 241));
        break;
    }

    _getProductLots();
  }

  void _getProductLots() async {
    try {
      final param = GetLotsRangeParam(
        startDate: _startDate.toUtc().toIso8601String(),
        endDate: _endDate.toUtc().toIso8601String(),
      );
      final result = await productRepo.getProductLots(param);
      for (var item in result) {
        item.product = await productRepo.getLocalProductById(item.productId);
      }
      _onListProductLotExpired(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setProductLots(List<ProductLot> data) {
    _lots.sink.add(data);
  }

  void _onLoading() {
    _states.sink.add(LoadingState());
  }

  void _onListProductLotExpired(List<ProductLot> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListExpiresState(
        data: data,
        totalCost: _calculateTotalCost(data),
      ));
    }
  }

  void _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  double _calculateTotalCost(List<ProductLot> data) {
    double total = 0;
    for (var x in data) {
      total += x.costPrice * x.quantity;
    }
    return total;
  }

  void dispose() {
    _states.close();
    _lots.close();
  }
}
