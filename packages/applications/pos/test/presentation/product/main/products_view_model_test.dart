import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/main/products_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> products;
  final Object? throws;

  FakeProductRepository({this.products = const [], this.throws});

  @override
  Future<List<Product>> getLocalProducts() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return products;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Product buildProduct(String id, String name, {int quantity = 0, String barcode = ''}) {
  return Product(
    id: id,
    name: name,
    description: '',
    unit: 'เม็ด',
    quantity: quantity,
    soldFirst: 0,
    serialNumber: 'sn-$id',
    status: 'ACTIVE',
    category: 'TABLET',
    minStock: 0,
    drugRegistrations: const [],
    createdDate: '2026-01-01',
    units: [
      ProductUnit(
        id: 'u-$id',
        productId: id,
        unit: 'เม็ด',
        size: 1,
        costPrice: 0,
        volume: 0,
        volumeUnit: '',
        barcode: barcode,
      ),
    ],
    prices: const [],
    stocks: const [],
  );
}

void main() {
  test('searchProduct with empty text returns all products', () async {
    final vm = ProductsViewModel(
      productRepo: FakeProductRepository(products: [
        buildProduct('1', 'พาราเซตามอล'),
        buildProduct('2', 'แอสไพริน'),
      ]),
    );

    await vm.searchProduct('', false);

    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.error, isNull);
  });

  test('searchProduct filters by name or barcode', () async {
    final vm = ProductsViewModel(
      productRepo: FakeProductRepository(products: [
        buildProduct('1', 'พาราเซตามอล', barcode: '885001'),
        buildProduct('2', 'แอสไพริน', barcode: '885002'),
      ]),
    );

    await vm.searchProduct('พารา', false);
    expect(vm.state.value.items.map((p) => p.id), ['1']);

    await vm.searchProduct('885002', false);
    expect(vm.state.value.items.map((p) => p.id), ['2']);
  });

  test('searchProduct maps a typed exception to state.error', () async {
    final vm = ProductsViewModel(
      productRepo: FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.searchProduct('', false);

    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.items, isEmpty);
  });
}
