import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';
import 'package:pos/domain/usecase/stock_count/create_stock_count_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_count_by_id_use_case.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_view_model.dart';

class Counts implements StockCountRepository {
  int calls = 0;
  final pending = Completer<StockCount>();
  @override
  Future<StockCount> createStockCount(CreateStockCountParam param) {
    calls++;
    return pending.future;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
StockCountItemParam item(int counted) => StockCountItemParam(productId: 'p1', stockId: 's1', counted: counted, productName: 'Product', lotNumber: 'LOT', systemQuantity: 5);
void main() {
  late Counts repo;
  late StockCountManageViewModel vm;
  setUp(() {
    repo = Counts();
    vm = StockCountManageViewModel(createStockCountUseCase: CreateStockCountUseCase(stockCountRepo: repo), getStockCountByIdUseCase: GetStockCountByIdUseCase(stockCountRepo: repo));
  });
  tearDown(() => vm.dispose());
  test('duplicate lot is rejected and original quantity preserved', () {
    vm.addItem(item(5)); vm.addItem(item(2));
    expect(vm.state.value.items, hasLength(1));
    expect(vm.state.value.items.single.counted, 5);
    expect(vm.state.value.error, isNotNull);
  });
  test('empty and invalid count never reach the API', () async {
    await vm.createStockCount('');
    vm.addItem(item(-1));
    await vm.createStockCount('');
    expect(repo.calls, 0);
    expect(vm.state.value.error, isNotNull);
  });
  // Invalidating the product cache moved to StockCountRepositoryImpl, where it
  // belongs; cache_invalidation_test covers it. This is about the submit.
  test('zero is valid and a pending submit is single', () async {
    vm.addItem(item(0));
    final request = vm.createStockCount('');
    await vm.createStockCount('');
    expect(repo.calls, 1);
    repo.pending.complete(StockCount(id: 'c1', countNo: 'SC1', note: '', items: [], createdDate: '2026-09-07'));
    await request;
    expect(vm.state.value.created?.id, 'c1');
  });
}
