import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/add_product_stock_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_stocks_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_stock_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_quantity_by_id_use_case.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_view_model.dart';
import 'package:pos/presentation/product/stock/product_stock_view_model.dart';

ProductStock stock(String id, {int quantity = 10, double price = 25}) {
  return ProductStock(
    id: id,
    unitId: 'u1',
    productId: 'p1',
    receiveCode: 'RC-1',
    sequence: 1,
    lotNumber: 'L1',
    costPrice: 12,
    price: price,
    import: quantity,
    quantity: quantity,
    expireDate: '2027-01-01T00:00:00Z',
    importDate: '2026-01-01T00:00:00Z',
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.stocks = const [], this.throws});

  final List<ProductStock> stocks;
  final Object? throws;
  final List<String> calls = [];

  void _guard(String call) {
    calls.add(call);
    final error = throws;
    if (error != null) throw error;
  }

  @override
  Future<List<ProductStock>> getProductStocksByProductId(String productId) async {
    _guard('get:$productId');
    return stocks;
  }

  @override
  Future<ProductStock> addProductStock(ProductStockParam param) async {
    _guard('add:${param.quantity}');
    return stock('new', quantity: param.quantity, price: param.price);
  }

  @override
  Future<ProductStock> updateProductStockById(
      String id, ProductStockParam param) async {
    _guard('update:$id');
    return stock(id, quantity: param.quantity, price: param.price);
  }

  @override
  Future<ProductStock> removeProductStockById(String id) async {
    _guard('remove:$id');
    return stock(id);
  }

  @override
  Future<ProductStock> updateProductStockQuantityById(
      String id, UpdateProductStockQuantityParam param) async {
    _guard('quantity:$id=${param.quantity}');
    return stock(id, quantity: param.quantity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductStockViewModel buildStockViewModel(FakeProductRepository repo) {
  return ProductStockViewModel(
    addProductStockUseCase: AddProductStockUseCase(productRepo: repo),
    updateProductStockByIdUseCase: UpdateProductStockByIdUseCase(productRepo: repo),
    removeProductStockByIdUseCase: RemoveProductStockByIdUseCase(productRepo: repo),
    getProductStocksByProductIdUseCase:
        GetProductStocksByProductIdUseCase(productRepo: repo),
  );
}

void main() {
  group('ProductStockViewModel', () {
    test('getProductStocks fills the lot list', () async {
      final repo = FakeProductRepository(stocks: [stock('a'), stock('b', quantity: 3)]);
      final viewModel = buildStockViewModel(repo);

      await viewModel.getProductStocks('p1');

      expect(viewModel.state.value.items, hasLength(2));
      expect(viewModel.state.value.items.last.quantity, 3);
      expect(viewModel.state.value.loading, isFalse);
    });

    test('addProductStock carries the entered quantity and price through',
        () async {
      final repo = FakeProductRepository();
      final viewModel = buildStockViewModel(repo);

      await viewModel.addProductStock(ProductStockParam(
        productId: 'p1',
        unitId: 'u1',
        quantity: 24,
        costPrice: 12,
        price: 30,
        lotNumber: 'L9',
        expireDate: '2027-01-01T00:00:00Z',
        importDate: '2026-01-01T00:00:00Z',
      ));

      expect(repo.calls, ['add:24']);
      expect(viewModel.state.value.completed?.quantity, 24);
      expect(viewModel.state.value.completed?.price, 30);
    });

    test('update and remove address the lot they were given', () async {
      final repo = FakeProductRepository();
      final viewModel = buildStockViewModel(repo);

      await viewModel.updateProductStockById(
        'stock-3',
        ProductStockParam(
          productId: 'p1',
          unitId: 'u1',
          quantity: 5,
          costPrice: 12,
          price: 25,
          lotNumber: 'L1',
          expireDate: '2027-01-01T00:00:00Z',
          importDate: '2026-01-01T00:00:00Z',
        ),
      );
      await viewModel.removeProductStockById('stock-4');

      expect(repo.calls, ['update:stock-3', 'remove:stock-4']);
    });

    test('a failed load surfaces the error and consumeError clears it',
        () async {
      final repo = FakeProductRepository(
        throws: const ServerException(message: 'boom', code: 'SERVER_ERROR'),
      );
      final viewModel = buildStockViewModel(repo);

      await viewModel.getProductStocks('p1');

      expect(viewModel.state.value.error, isNotNull);
      expect(viewModel.state.value.loading, isFalse);

      viewModel.consumeError();
      expect(viewModel.state.value.error, isNull);
    });
  });

  group('ProductStockQuantityViewModel', () {
    ProductStockQuantityViewModel build(FakeProductRepository repo) {
      return ProductStockQuantityViewModel(
        updateProductStockQuantityByIdUseCase:
            UpdateProductStockQuantityByIdUseCase(productRepo: repo),
      );
    }

    test('a corrected count reaches the addressed lot', () async {
      final repo = FakeProductRepository();
      final viewModel = build(repo);

      await viewModel.updateProductStockQuantityById(
          'stock-1', UpdateProductStockQuantityParam(quantity: 7));

      expect(repo.calls, ['quantity:stock-1=7']);
      expect(viewModel.state.value.updated?.quantity, 7);
      expect(viewModel.state.value.loading, isFalse);
    });

    test('zero is a legitimate count, not an empty update', () async {
      final repo = FakeProductRepository();
      final viewModel = build(repo);

      await viewModel.updateProductStockQuantityById(
          'stock-1', UpdateProductStockQuantityParam(quantity: 0));

      expect(repo.calls, ['quantity:stock-1=0']);
      expect(viewModel.state.value.updated?.quantity, 0);
    });

    test('a rejected correction leaves nothing marked as updated', () async {
      final repo = FakeProductRepository(
        throws: const ValidationException(message: 'invalid', code: 'VA-400'),
      );
      final viewModel = build(repo);

      await viewModel.updateProductStockQuantityById(
          'stock-1', UpdateProductStockQuantityParam(quantity: -1));

      expect(viewModel.state.value.updated, isNull);
      expect(viewModel.state.value.error, isNotNull);
    });

    test('consumeUpdated clears the one-shot result', () async {
      final viewModel = build(FakeProductRepository());

      await viewModel.updateProductStockQuantityById(
          'stock-1', UpdateProductStockQuantityParam(quantity: 4));
      expect(viewModel.state.value.updated, isNotNull);

      viewModel.consumeUpdated();
      expect(viewModel.state.value.updated, isNull);
    });
  });
}
