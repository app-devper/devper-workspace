// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
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

  /// A finished count closes the screen; a rejected edit flashes a message.
  /// Neither is drawn, so neither sits in state waiting to be cleared.
  final _created = OneShot<StockCount>();
  final _errors = OneShot<String>();

  ValueListenable<StockCountManageState> get state => _state;

  Stream<StockCount> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getStockCountById(String? stockCountId) async {
    if (stockCountId == null) {
      return;
    }
    _state.value = _state.value.copyWith(loading: true);
    try {
      final stockCount = await getStockCountByIdUseCase(stockCountId);
      _state.value = _state.value.copyWith(stockCount: stockCount);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void addItem(StockCountItemParam item) {
    if (_state.value.items
        .any((existing) => existing.stockId == item.stockId)) {
      _errors.emit("ล็อตนี้อยู่ในรายการตรวจนับแล้ว");
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
      _errors.emit("โปรดระบุจำนวนตรวจนับเป็นจำนวนเต็มตั้งแต่ 0 ทุกรายการ");
      return;
    }
    _state.value = _state.value.copyWith(loading: true);
    try {
      final created = await createStockCountUseCase(
        CreateStockCountParam(note: note, items: _state.value.items),
      );
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
