// Flutter imports:
import 'package:flutter/foundation.dart';

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

  final _state = ValueNotifier<ProductsExpiredState>(const ProductsExpiredState());

  ValueListenable<ProductsExpiredState> get state => _state;

  late DateTime _startDate;
  late DateTime _endDate;

  void initData() {
    final ranges = [
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
    _state.value = _state.value.copyWith(ranges: ranges);
  }

  Future<void> selectRange(Range range) async {
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
    await _getProductLots();
  }

  Future<void> _getProductLots() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final param = GetLotsRangeParam(
        startDate: _startDate.toUtc().toIso8601String(),
        endDate: _endDate.toUtc().toIso8601String(),
      );
      final items = await productRepo.getProductLots(param);
      for (var item in items) {
        item.product = await productRepo.getLocalProductById(item.productId);
      }
      _state.value = _state.value.copyWith(
        loading: false,
        items: items,
        totalCost: _calculateTotalCost(items),
      );
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  double _calculateTotalCost(List<ProductLot> data) {
    double total = 0;
    for (var x in data) {
      total += x.costPrice * x.quantity;
    }
    return total;
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
