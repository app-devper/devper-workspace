import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/update_product_stock_sequence_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_state.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final Object? throws;
  UpdateProductStockSequenceParam? received;

  FakeProductRepository({this.throws});

  @override
  Future<List<ProductStock>> updateProductStockSequence(
      UpdateProductStockSequenceParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    received = param;
    return [
      for (final stock in param.stocks)
        buildStock(stock.stockId, stock.sequence),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductStock buildStock(String id, int sequence) {
  return ProductStock(
    id: id,
    unitId: 'unit-1',
    productId: 'product-1',
    receiveCode: '',
    sequence: sequence,
    lotNumber: 'LOT-$id',
    costPrice: 5,
    price: 10,
    import: 10,
    quantity: 10,
    expireDate: '',
    importDate: '',
  );
}

UpdateProductStockSequenceParam buildParam() {
  return UpdateProductStockSequenceParam(
    productId: 'product-1',
    stocks: [
      ProductStockSequenceParam(stockId: 'stock-b', sequence: 1),
      ProductStockSequenceParam(stockId: 'stock-a', sequence: 2),
    ],
  );
}

ProductStockSequenceViewModel buildViewModel(ProductRepository repo) {
  return ProductStockSequenceViewModel(
    updateProductStockSequenceUseCase:
        UpdateProductStockSequenceUseCase(productRepo: repo),
  );
}

void main() {
  test('a reorder publishes the stocks in their new sequence', () async {
    final repo = FakeProductRepository();
    final vm = buildViewModel(repo);

    await vm.updateProductStockSequenceById(buildParam());

    expect(vm.state.value.task, isA<ProductStockSequenceUpdated>());
    expect(vm.state.value.updated?.map((e) => e.id), ['stock-b', 'stock-a']);
    expect(vm.state.value.updated?.map((e) => e.sequence), [1, 2]);
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNull);
    expect(repo.received?.productId, 'product-1');
  });

  test('a failure leaves no result behind', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateProductStockSequenceById(buildParam());

    expect(vm.state.value.task, isA<ProductStockSequenceFailed>());
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.loading, isFalse);
  });

  test('a retry after a failure clears the error', () async {
    final failing = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    await failing.updateProductStockSequenceById(buildParam());
    expect(failing.state.value.error, isNotNull);

    final vm = buildViewModel(FakeProductRepository());
    await vm.updateProductStockSequenceById(buildParam());

    expect(vm.state.value.error, isNull);
    expect(vm.state.value.updated, isNotNull);
  });

  test('consumeUpdated returns the screen to idle', () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.updateProductStockSequenceById(buildParam());
    expect(vm.state.value.updated, isNotNull);

    vm.consumeUpdated();

    expect(vm.state.value.task, isA<ProductStockSequenceIdle>());
    expect(vm.state.value.updated, isNull);
  });

  test('consumeError leaves an unread result alone', () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.updateProductStockSequenceById(buildParam());
    vm.consumeError();

    expect(vm.state.value.updated, isNotNull,
        reason: 'consuming an error must not discard an unread result');
  });
}
