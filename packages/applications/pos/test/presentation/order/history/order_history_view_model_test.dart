import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/usecase/order/get_order_item_by_product_id_use_case.dart';
import 'package:pos/presentation/order/history/order_history_view_model.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderItemDetail> items;
  final Object? throws;
  String? requestedProductId;

  FakeOrderRepository({this.items = const [], this.throws});

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(
      String productId) async {
    requestedProductId = productId;
    final error = throws;
    if (error != null) {
      throw error;
    }
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

OrderItemDetail buildItem(String id) {
  return OrderItemDetail(
    id: id,
    product: null,
    quantity: 2,
    price: 10,
    costPrice: 5,
    discount: 0,
    createdDate: '2026-01-01T00:00:00.000Z',
    order: null,
  );
}

OrderHistoryViewModel buildViewModel(OrderRepository repo) {
  return OrderHistoryViewModel(
    getOrderItemByProductIdUseCase:
        GetOrderItemByProductIdUseCase(orderRepo: repo),
  );
}

void main() {
  test('loads the sales history for one product', () async {
    final repo = FakeOrderRepository(items: [buildItem('i1'), buildItem('i2')]);
    final vm = buildViewModel(repo);

    await vm.getOrderItemByProductId('product-1');

    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNull);
    expect(repo.requestedProductId, 'product-1');
  });

  test('an empty history is not an error', () async {
    final vm = buildViewModel(FakeOrderRepository());

    await vm.getOrderItemByProductId('product-1');

    expect(vm.state.value.items, isEmpty);
    expect(vm.state.value.error, isNull,
        reason: 'a product that has never sold is a normal answer');
  });

  test('a failed read surfaces instead of showing an empty history', () async {
    final vm = buildViewModel(
      FakeOrderRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getOrderItemByProductId('product-1');

    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items, isEmpty);
  });

  test('a retry clears the previous error before it starts', () async {
    final repo = _FlakyOrderRepository();
    final vm = buildViewModel(repo);

    await vm.getOrderItemByProductId('product-1');
    expect(vm.state.value.error, isNotNull);

    await vm.getOrderItemByProductId('product-1');

    expect(vm.state.value.error, isNull);
    expect(vm.state.value.items, hasLength(1));
  });

  test('consumeError clears the error and leaves the items', () async {
    final repo = _FlakyOrderRepository();
    final vm = buildViewModel(repo);

    await vm.getOrderItemByProductId('product-1');
    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}

/// Throws the first time, succeeds afterwards.
class _FlakyOrderRepository implements OrderRepository {
  int calls = 0;

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(
      String productId) async {
    calls++;
    if (calls == 1) {
      throw const NetworkException(message: 'offline');
    }
    return [buildItem('i1')];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
