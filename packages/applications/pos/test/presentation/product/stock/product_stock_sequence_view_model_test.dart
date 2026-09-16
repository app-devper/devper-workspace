import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/update_product_stock_sequence_use_case.dart';
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
  test('a reorder emits the stocks in their new sequence', () async {
    final repo = FakeProductRepository();
    final vm = buildViewModel(repo);
    final updated = <List<ProductStock>>[];
    vm.updated.listen(updated.add);

    await vm.updateProductStockSequenceById(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(updated.single.map((e) => e.id), ['stock-b', 'stock-a']);
    expect(updated.single.map((e) => e.sequence), [1, 2]);
    expect(vm.state.value.loading, isFalse);
    expect(repo.received?.productId, 'product-1');
  });

  test('a failure emits an error and no result', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    final updated = <List<ProductStock>>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateProductStockSequenceById(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(updated, isEmpty);
    expect(vm.state.value.loading, isFalse);
  });

  test('a retry after a failure reports each attempt on its own channel',
      () async {
    final failing = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    final errors = <String>[];
    failing.errors.listen(errors.add);
    await failing.updateProductStockSequenceById(buildParam());

    final retry = buildViewModel(FakeProductRepository());
    final updated = <List<ProductStock>>[];
    retry.updated.listen(updated.add);
    await retry.updateProductStockSequenceById(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(updated, hasLength(1),
        reason: 'each attempt reports on its own channel, once');
  });

  test('the result is delivered once, with nothing to clear', () async {
    final vm = buildViewModel(FakeProductRepository());
    final updated = <List<ProductStock>>[];
    vm.updated.listen(updated.add);

    await vm.updateProductStockSequenceById(buildParam());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(updated, hasLength(1));
  });
}
