// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/usecase/stock_count/create_stock_count_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_count_by_id_use_case.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_state.dart';

class StockCountManageViewModel {
  final CreateStockCountUseCase createStockCountUseCase;
  final GetStockCountByIdUseCase getStockCountByIdUseCase;

  StockCountManageViewModel({
    required this.createStockCountUseCase,
    required this.getStockCountByIdUseCase,
  });

  final _state =
      ValueNotifier<StockCountManageState>(const StockCountManageState());

  ValueListenable<StockCountManageState> get state => _state;

  Future<void> getStockCountById(String? stockCountId) async {
    if (stockCountId == null) {
      return;
    }
    _state.value = _state.value.copyWith(task: const StockCountManageRunning());
    try {
      final stockCount = await getStockCountByIdUseCase(stockCountId);
      _state.value = _state.value
          .copyWith(task: const StockCountManageTask(), stockCount: stockCount);
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: StockCountManageFailed(toFailure(e)));
    }
  }

  void addItem(StockCountItemParam item) {
    if (_state.value.items
        .any((existing) => existing.stockId == item.stockId)) {
      _state.value = _state.value.copyWith(
          task:
              const StockCountManageRejected("ล็อตนี้อยู่ในรายการตรวจนับแล้ว"));
      return;
    }
    final items = List<StockCountItemParam>.of(_state.value.items)..add(item);
    _state.value = _state.value.copyWith(items: items);
  }

  void removeItem(int index) {
    final items = List<StockCountItemParam>.of(_state.value.items)
      ..removeAt(index);
    _state.value = _state.value.copyWith(items: items);
  }

  void updateCounted(int index, int counted) {
    final items = List<StockCountItemParam>.of(_state.value.items);
    final current = items[index];
    items[index] = StockCountItemParam(
      productId: current.productId,
      stockId: current.stockId,
      counted: counted,
      productName: current.productName,
      lotNumber: current.lotNumber,
      systemQuantity: current.systemQuantity,
    );
    _state.value = _state.value.copyWith(items: items);
  }

  Future<void> createStockCount(String note) async {
    if (_state.value.loading) return;
    if (_state.value.items.isEmpty ||
        _state.value.items.any((item) => item.counted < 0)) {
      _state.value = _state.value.copyWith(
          task: const StockCountManageRejected(
              "โปรดระบุจำนวนตรวจนับเป็นจำนวนเต็มตั้งแต่ 0 ทุกรายการ"));
      return;
    }
    _state.value = _state.value.copyWith(task: const StockCountManageRunning());
    try {
      final created = await createStockCountUseCase(
        CreateStockCountParam(note: note, items: _state.value.items),
      );
      _state.value =
          _state.value.copyWith(task: StockCountManageCreated(created));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: StockCountManageFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is StockCountManageFailed ||
        _state.value.task is StockCountManageRejected) {
      _state.value = _state.value.copyWith(task: const StockCountManageTask());
    }
  }

  void consumeCreated() {
    if (_state.value.task is StockCountManageCreated) {
      _state.value = _state.value.copyWith(task: const StockCountManageTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
