import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_product_histories_by_product_id_use_case.dart';
import 'package:pos/presentation/product/history/product_history_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductHistory> histories;
  final Object? throws;
  String? requestedProductId;

  FakeProductRepository({this.histories = const [], this.throws});

  @override
  Future<List<ProductHistory>> getProductHistoriesByProductId(
      String productId) async {
    requestedProductId = productId;
    final error = throws;
    if (error != null) {
      throw error;
    }
    return histories;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductHistory buildHistory(String id, {int balance = 10}) {
  return ProductHistory(
    id: id,
    productId: 'product-1',
    type: 'RECEIVE',
    description: 'รับเข้า',
    unit: 'เม็ด',
    import: 10,
    quantity: 10,
    costPrice: 5,
    price: 10,
    balance: balance,
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

ProductHistoryViewModel buildViewModel(ProductRepository repo) {
  return ProductHistoryViewModel(
    getProductHistoriesByProductIdUseCase:
        GetProductHistoriesByProductIdUseCase(productRepo: repo),
  );
}

void main() {
  test('loads the stock movements for one product', () async {
    final repo = FakeProductRepository(
      histories: [buildHistory('h1'), buildHistory('h2', balance: 20)],
    );
    final vm = buildViewModel(repo);

    await vm.getHistoriesByProductId('product-1');

    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.items.last.balance, 20);
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNull);
    expect(repo.requestedProductId, 'product-1');
  });

  test('a product with no movements is not an error', () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.getHistoriesByProductId('product-1');

    expect(vm.state.value.items, isEmpty);
    expect(vm.state.value.error, isNull);
  });

  test('a failed read surfaces rather than reading as an empty ledger',
      () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getHistoriesByProductId('product-1');

    expect(vm.state.value.error, isNotNull,
        reason: 'an empty movement list and a failed read must not look alike');
    expect(vm.state.value.items, isEmpty);
    expect(vm.state.value.loading, isFalse);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getHistoriesByProductId('product-1');
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
