import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';
import 'package:pos/domain/usecase/stock_count/create_stock_count_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_count_by_id_use_case.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_view_model.dart';
import 'package:pos/domain/repositories/product_repository.dart';

/// The mutation use cases invalidate the product cache after writing, so they
/// need a repository even though these tests only assert on the write.
class FakeProductRepository implements ProductRepository {
  var invalidated = 0;

  @override
  void invalidateProductsCache() => invalidated++;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeStockCountRepository implements StockCountRepository {
  final StockCount result;
  final Object? error;
  CreateStockCountParam? createParam;
  var getByIdCalls = 0;

  FakeStockCountRepository({
    StockCount? result,
    this.error,
  }) : result = result ?? buildStockCount('sc1');

  void _throwIfNeeded() {
    if (error != null) throw error!;
  }

  @override
  Future<StockCount> createStockCount(CreateStockCountParam param) async {
    _throwIfNeeded();
    createParam = param;
    return result;
  }

  @override
  Future<StockCount> getStockCountById(String stockCountId) async {
    _throwIfNeeded();
    getByIdCalls++;
    return result;
  }

  @override
  Future<List<StockCount>> getStockCounts() async => [result];
}

StockCount buildStockCount(String id) {
  return StockCount(
    id: id,
    countNo: 'COUNT-1',
    note: 'monthly',
    items: const [],
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

StockCountItemParam buildItem({
  String productId = 'p1',
  int counted = 8,
  int systemQuantity = 10,
}) {
  return StockCountItemParam(
    productId: productId,
    stockId: 'stock-$productId',
    counted: counted,
    productName: 'Product $productId',
    lotNumber: 'LOT-1',
    systemQuantity: systemQuantity,
  );
}

StockCountManageViewModel buildViewModel(StockCountRepository repository) {
  return StockCountManageViewModel(
    createStockCountUseCase: CreateStockCountUseCase(
      stockCountRepo: repository,
          productRepo: FakeProductRepository(),
    ),
    getStockCountByIdUseCase: GetStockCountByIdUseCase(
      stockCountRepo: repository,
    ),
  );
}

void main() {
  test('getStockCountById loads an existing count', () async {
    final repository = FakeStockCountRepository(
      result: buildStockCount('sc7'),
    );
    final vm = buildViewModel(repository);

    await vm.getStockCountById('sc7');

    expect(repository.getByIdCalls, 1);
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.stockCount?.id, 'sc7');
    expect(vm.state.value.error, isNull);
  });

  test('getStockCountById ignores a null id', () async {
    final repository = FakeStockCountRepository();
    final vm = buildViewModel(repository);

    await vm.getStockCountById(null);

    expect(repository.getByIdCalls, 0);
    expect(vm.state.value.stockCount, isNull);
  });

  test('getStockCountById maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeStockCountRepository(
        error: const NetworkException(message: 'offline'),
      ),
    );

    await vm.getStockCountById('sc1');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.stockCount, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('add, update, and remove item produce immutable list changes', () {
    final vm = buildViewModel(FakeStockCountRepository());
    final first = buildItem();

    vm.addItem(first);
    final firstList = vm.state.value.items;
    expect(firstList.single.counted, 8);

    vm.updateCounted(0, 12);
    final updatedList = vm.state.value.items;
    expect(updatedList.single.counted, 12);
    expect(updatedList.single.systemQuantity, 10);
    expect(updatedList, isNot(same(firstList)));

    vm.removeItem(0);
    expect(vm.state.value.items, isEmpty);
  });

  test('createStockCount sends the current items and exposes result', () async {
    final repository = FakeStockCountRepository(
      result: buildStockCount('created'),
    );
    final vm = buildViewModel(repository);
    vm.addItem(buildItem(productId: 'p9'));

    await vm.createStockCount('cycle count');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.created?.id, 'created');
    expect(repository.createParam?.note, 'cycle count');
    expect(repository.createParam?.items.single.productId, 'p9');

    vm.consumeCreated();
    expect(vm.state.value.created, isNull);
  });

  test('createStockCount maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeStockCountRepository(
        error: const NetworkException(message: 'offline'),
      ),
    );

    await vm.createStockCount('cycle count');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();
    expect(vm.state.value.error, isNull);
  });
}
