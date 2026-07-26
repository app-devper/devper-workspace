import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/presentation/home/main/product_search_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> products;
  final Object? error;

  FakeProductRepository({this.products = const [], this.error});

  @override
  Future<List<Product>> getLocalProducts() async {
    if (error != null) throw error!;
    return products;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Product buildProduct(String id, String name, String barcode) {
  return Product(
    id: id,
    name: name,
    status: productStatusActive,
    category: 'Medicine',
    createdDate: '2026-01-01',
    units: [
      ProductUnit(
        id: 'unit-$id',
        productId: id,
        costPrice: 10,
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

ProductSearchViewModel buildViewModel(ProductRepository repository) {
  return ProductSearchViewModel(
    getLocalProductsUseCase: GetLocalProductsUseCase(productRepo: repository),
  );
}

void main() {
  test('getProducts loads active product units', () async {
    final vm = buildViewModel(
      FakeProductRepository(
        products: [buildProduct('1', 'พาราเซตามอล', '885001')],
      ),
    );

    await vm.getProducts();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items.single.id, '1');
    expect(vm.state.value.error, isNull);
  });

  test('searchProduct filters by barcode', () async {
    final vm = buildViewModel(
      FakeProductRepository(
        products: [
          buildProduct('1', 'พาราเซตามอล', '885001'),
          buildProduct('2', 'แอสไพริน', '885002'),
        ],
      ),
    );

    await vm.getProducts();
    vm.searchProduct('885002');

    expect(vm.state.value.items.map((item) => item.id), ['2']);
  });

  test('getProducts maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeProductRepository(
        error: const NetworkException(message: 'offline'),
      ),
    );

    await vm.getProducts();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNotNull);
  });
}
