import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/presentation/home/scanner/scanner_state.dart';
import 'package:pos/presentation/home/scanner/scanner_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final Product? product;
  final Object? throws;
  final List<String> lookups = [];

  FakeProductRepository({this.product, this.throws});

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    lookups.add(barcode);
    final error = throws;
    if (error != null) {
      throw error;
    }
    return product;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Product buildProduct(String barcode) {
  return Product(
    id: 'product-1',
    name: 'ยาแก้ปวด',
    status: productStatusActive,
    category: 'General',
    createdDate: '',
    units: [
      ProductUnit(
        id: 'unit-1',
        productId: 'product-1',
        costPrice: 5,
        unit: 'เม็ด',
        size: 1,
        barcode: barcode,
        volume: 0,
        volumeUnit: '',
      ),
    ],
    prices: const [],
    stocks: const [],
  );
}

ScannerViewModel buildViewModel(ProductRepository repo) {
  return ScannerViewModel(
    getProductByBarcodeUseCase: GetProductByBarcodeUseCase(productRepo: repo),
  );
}

void main() {
  test('a scan that matches publishes the product', () async {
    final product = buildProduct('8850001');
    final repo = FakeProductRepository(product: product);
    final vm = buildViewModel(repo);

    await vm.getProductBySerialNumber('8850001');

    expect(vm.state.value.task, isA<ScannerLoaded>());
    expect(vm.state.value.loaded, product);
    expect(vm.state.value.error, isNull);
    expect(vm.state.value.loading, isFalse);
    expect(repo.lookups, ['8850001']);
  });

  test('an unknown barcode is rejected, not reported as a failure', () async {
    // The repository answers null rather than throwing: the request worked,
    // the shop just does not carry that barcode.
    final vm = buildViewModel(FakeProductRepository());

    await vm.getProductBySerialNumber('0000000');

    expect(vm.state.value.task, isA<ScannerRejected>());
    expect(vm.state.value.error, 'ไม่พบสินค้า');
    expect(vm.state.value.loaded, isNull);
  });

  test('a rejection carries the message alone, with no error code', () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.getProductBySerialNumber('0000000');

    // A Failure renders as "message [CODE]"; this message is the screen's own
    // and must not pick up a code it never had.
    expect(vm.state.value.error, isNot(contains('[')));
  });

  test('a failed request maps to the typed failure', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getProductBySerialNumber('8850001');

    expect(vm.state.value.task, isA<ScannerFailed>());
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.loaded, isNull);
  });

  test('consumeError clears a rejection as well as a failure', () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.getProductBySerialNumber('0000000');
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.task, isA<ScannerIdle>());
    expect(vm.state.value.error, isNull);
  });

  test('consumeLoaded leaves a failure alone', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getProductBySerialNumber('8850001');
    vm.consumeLoaded();

    expect(vm.state.value.task, isA<ScannerFailed>(),
        reason: 'consuming a result must not swallow an unread error');
  });

  test('a second scan replaces the first result', () async {
    final repo = FakeProductRepository(product: buildProduct('8850001'));
    final vm = buildViewModel(repo);

    await vm.getProductBySerialNumber('8850001');
    expect(vm.state.value.loaded, isNotNull);

    final rejecting = FakeProductRepository();
    final vm2 = buildViewModel(rejecting);
    await vm2.getProductBySerialNumber('0000000');

    expect(vm2.state.value.loaded, isNull);
    expect(vm2.state.value.error, isNotNull);
  });
}
