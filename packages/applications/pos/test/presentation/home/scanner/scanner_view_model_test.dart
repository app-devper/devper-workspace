import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
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
  test('a scan that matches emits the product', () async {
    final product = buildProduct('8850001');
    final repo = FakeProductRepository(product: product);
    final vm = buildViewModel(repo);
    final loaded = <Product>[];
    final errors = <String>[];
    vm.loaded.listen(loaded.add);
    vm.errors.listen(errors.add);

    await vm.getProductBySerialNumber('8850001');
    await Future<void>.delayed(Duration.zero);

    expect(loaded.single, product);
    expect(errors, isEmpty);
    expect(vm.state.value.loading, isFalse);
    expect(repo.lookups, ['8850001']);
  });

  test('an unknown barcode says so, in those words', () async {
    // The repository answers null rather than throwing: the request worked,
    // the shop just does not carry that barcode. The page used to replace this
    // with "ไม่สามารถค้นหาสินค้าได้", which claims the search itself failed.
    final vm = buildViewModel(FakeProductRepository());
    final loaded = <Product>[];
    final errors = <String>[];
    vm.loaded.listen(loaded.add);
    vm.errors.listen(errors.add);

    await vm.getProductBySerialNumber('0000000');
    await Future<void>.delayed(Duration.zero);

    expect(errors.single, 'ไม่พบสินค้า');
    expect(loaded, isEmpty);
  });

  test('a miss carries the message alone, with no error code', () async {
    final vm = buildViewModel(FakeProductRepository());
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getProductBySerialNumber('0000000');
    await Future<void>.delayed(Duration.zero);

    // A Failure renders as "message [CODE]"; this message is the screen's own
    // and must not pick up a code it never had.
    expect(errors.single, isNot(contains('[')));
  });

  test('a failed request emits the typed failure, not a miss', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    final loaded = <Product>[];
    final errors = <String>[];
    vm.loaded.listen(loaded.add);
    vm.errors.listen(errors.add);

    await vm.getProductBySerialNumber('8850001');
    await Future<void>.delayed(Duration.zero);

    expect(errors.single, isNot('ไม่พบสินค้า'),
        reason: 'a network failure and an unstocked barcode read differently');
    expect(loaded, isEmpty);
  });

  test('two scans deliver two results', () async {
    final repo = FakeProductRepository(product: buildProduct('8850001'));
    final vm = buildViewModel(repo);
    final loaded = <Product>[];
    vm.loaded.listen(loaded.add);

    await vm.getProductBySerialNumber('8850001');
    await vm.getProductBySerialNumber('8850001');
    await Future<void>.delayed(Duration.zero);

    expect(loaded, hasLength(2));
  });
}
