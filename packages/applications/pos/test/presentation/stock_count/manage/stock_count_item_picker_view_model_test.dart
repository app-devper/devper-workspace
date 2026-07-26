import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_item_picker_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> products;
  final Object? error;

  FakeProductRepository({this.products = const [], this.error});

  @override
  Future<List<Product>> getLocalProducts() async {
    if (error != null) {
      throw error!;
    }
    return products;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Product buildProduct(String id, String name, {required String status}) {
  return Product(
    id: id,
    name: name,
    status: status,
    category: 'Medicine',
    createdDate: '2026-01-01',
    units: [
      ProductUnit(
        id: 'unit-$id',
        productId: id,
        costPrice: 10,
        unit: 'เม็ด',
        size: 1,
        barcode: 'barcode-$id',
        volume: 0,
        volumeUnit: '',
      ),
    ],
    prices: const [],
    stocks: const [],
  );
}

StockCountItemPickerViewModel buildViewModel(ProductRepository repository) {
  return StockCountItemPickerViewModel(
    getLocalProductsUseCase: GetLocalProductsUseCase(productRepo: repository),
  );
}

void main() {
  test('getProducts exposes product units from active products only', () async {
    final vm = buildViewModel(
      FakeProductRepository(
        products: [
          buildProduct('1', 'พาราเซตามอล', status: productStatusActive),
          buildProduct('2', 'ยกเลิกแล้ว', status: productStatusInactive),
        ],
      ),
    );

    await vm.getProducts();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.products.map((item) => item.id), ['1']);
    expect(vm.state.value.error, isNull);
  });

  test('searchProduct filters the cached product units by name', () async {
    final vm = buildViewModel(
      FakeProductRepository(
        products: [
          buildProduct('1', 'พาราเซตามอล', status: productStatusActive),
          buildProduct('2', 'แอสไพริน', status: productStatusActive),
        ],
      ),
    );

    await vm.getProducts();
    vm.searchProduct('พารา');

    expect(vm.state.value.products.map((item) => item.id), ['1']);
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

    vm.consumeError();
    expect(vm.state.value.error, isNull);
  });
}
