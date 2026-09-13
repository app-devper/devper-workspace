// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/usecase/stock_count/get_stock_counts_use_case.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_state.dart';

class StockCountsViewModel {
  final GetStockCountsUseCase getStockCountsUseCase;

  StockCountsViewModel({
    required this.getStockCountsUseCase,
  });

  final _state = ValueNotifier<StockCountsState>(const StockCountsState());

  /// Shown as a snackbar and then gone. It never belonged in state: a message
  /// the view had to remember to clear is one it can forget to clear.
  final _errors = OneShot<String>();

  ValueListenable<StockCountsState> get state => _state;

  Stream<String> get errors => _errors.stream;

  Future<void> getStockCounts() async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await getStockCountsUseCase();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  void dispose() {
    _state.dispose();
    _errors.dispose();
  }
}
