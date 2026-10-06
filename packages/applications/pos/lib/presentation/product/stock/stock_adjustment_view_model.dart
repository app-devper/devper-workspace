// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_state.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class StockAdjustmentViewModel {
  final StockAdjustmentRepository stockAdjustmentRepo;

  StockAdjustmentViewModel({
    required this.stockAdjustmentRepo,
  });

  final _state =
      ValueNotifier<StockAdjustmentState>(const StockAdjustmentState());

  /// Delivered once: the sheet closes on it, nothing draws it.
  final _created = OneShot<StockAdjustment>();
  final _errors = OneShot<String>();

  ValueListenable<StockAdjustmentState> get state => _state;

  Stream<StockAdjustment> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> createStockAdjustment(CreateStockAdjustmentParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final created = await stockAdjustmentRepo.createStockAdjustment(param);
      _created.emit(created);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _errors.dispose();
  }
}
