import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/add_product_price_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_price_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_price_by_id_use_case.dart';
import 'package:pos/presentation/product/price/product_price_state.dart';
import 'package:pos/presentation/product/price/product_price_view_model.dart';

ProductPrice price(String id, double amount,
    {String customerType = 'GENERAL'}) {
  return ProductPrice(
    id: id,
    productId: 'p1',
    unitId: 'u1',
    customerType: customerType,
    price: amount,
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.prices = const [], this.throws});

  final List<ProductPrice> prices;
  Object? throws;
  final List<String> calls = [];

  void _guard(String call) {
    calls.add(call);
    final error = throws;
    if (error != null) throw error;
  }

  @override
  Future<List<ProductPrice>> getProductPricesByProductId(
      String productId) async {
    _guard('get:$productId');
    return prices;
  }

  @override
  Future<ProductPrice> addProductPrice(ProductPriceParam param) async {
    _guard('add:${param.price}');
    return price('new', param.price, customerType: param.customerType);
  }

  @override
  Future<ProductPrice> updateProductPriceById(
      String id, ProductPriceParam param) async {
    _guard('update:$id');
    return price(id, param.price);
  }

  @override
  Future<ProductPrice> removeProductPriceById(String priceId) async {
    _guard('remove:$priceId');
    return price(priceId, 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductPriceViewModel buildViewModel(FakeProductRepository repo) {
  return ProductPriceViewModel(
    addProductPriceUseCase: AddProductPriceUseCase(productRepo: repo),
    updateProductPriceByIdUseCase:
        UpdateProductPriceByIdUseCase(productRepo: repo),
    removeProductPriceByIdUseCase:
        RemoveProductPriceByIdUseCase(productRepo: repo),
    getProductPricesByProductIdUseCase:
        GetProductPricesByProductIdUseCase(productRepo: repo),
  );
}

void main() {
  test('getProductPrice fills the tier list and clears loading', () async {
    final repo = FakeProductRepository(prices: [
      price('a', 25),
      price('b', 20, customerType: 'WHOLESALE'),
    ]);
    final viewModel = buildViewModel(repo);

    await viewModel.getProductPrice('p1');

    expect(viewModel.state.value.items, hasLength(2));
    expect(viewModel.state.value.items.map((e) => e.price), [25, 20]);
    expect(viewModel.state.value.loading, isFalse);
    expect(viewModel.state.value.error, isNull);
  });

  test('addProductPrice exposes the created tier as completed', () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);

    await viewModel.addProductPrice(ProductPriceParam(
      productId: 'p1',
      unitId: 'u1',
      customerType: 'WHOLESALE',
      price: 18.5,
    ));

    expect(repo.calls, ['add:18.5']);
    expect(viewModel.state.value.completed?.price, 18.5);
    expect(viewModel.state.value.completed?.customerType, 'WHOLESALE');
    expect(viewModel.state.value.loading, isFalse);
  });

  test('updateProductPriceById addresses the tier being edited', () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);

    await viewModel.updateProductPriceById(
      'price-7',
      ProductPriceParam(
          productId: 'p1', unitId: 'u1', customerType: 'GENERAL', price: 30),
    );

    expect(repo.calls, ['update:price-7']);
    expect(viewModel.state.value.completed?.price, 30);
  });

  test('removeProductPriceById addresses the tier being deleted', () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);

    await viewModel.removeProductPriceById('price-9');

    expect(repo.calls, ['remove:price-9']);
    expect(viewModel.state.value.completed, isNotNull);
  });

  test('a failed load reports the error and leaves the list alone', () async {
    final repo = FakeProductRepository(
      throws: const NetworkException(message: 'down', code: 'NETWORK_ERROR'),
    );
    final viewModel = buildViewModel(repo);

    await viewModel.getProductPrice('p1');

    expect(viewModel.state.value.loading, isFalse);
    expect(viewModel.state.value.error, contains('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้'));
    expect(viewModel.state.value.items, isEmpty);
  });

  test('a failed write reports the error and completes nothing', () async {
    final repo = FakeProductRepository(
      throws: const ForbiddenException(message: 'nope', code: 'AU-403'),
    );
    final viewModel = buildViewModel(repo);

    await viewModel.addProductPrice(ProductPriceParam(
        productId: 'p1', unitId: 'u1', customerType: 'GENERAL', price: 10));

    expect(viewModel.state.value.completed, isNull);
    expect(viewModel.state.value.error, isNotNull);

    viewModel.consumeError();
    expect(viewModel.state.value.error, isNull);
  });

  test('consumeCompleted clears the one-shot result', () async {
    final viewModel = buildViewModel(FakeProductRepository());

    await viewModel.removeProductPriceById('price-1');
    expect(viewModel.state.value.completed, isNotNull);

    viewModel.consumeCompleted();
    expect(viewModel.state.value.completed, isNull);
  });

  group('one flow at a time', () {
    test('reloading the list drops the tier the last write completed',
        () async {
      final repo = FakeProductRepository(prices: [price('a', 25)]);
      final viewModel = buildViewModel(repo);

      await viewModel.addProductPrice(ProductPriceParam(
        productId: 'p1',
        unitId: 'u1',
        customerType: 'WHOLESALE',
        price: 18.5,
      ));
      expect(viewModel.state.value.completed, isNotNull);

      await viewModel.getProductPrice('p1');

      expect(viewModel.state.value.items, hasLength(1),
          reason: 'the list is data and survives');
      expect(viewModel.state.value.completed, isNull,
          reason: 'the write result belongs to the write that produced it');
      expect(viewModel.state.value.task, isA<ProductPriceIdle>());
    });

    test('a failure drops the previous result but keeps the list', () async {
      final repo = FakeProductRepository(prices: [price('a', 25)]);
      final viewModel = buildViewModel(repo);

      await viewModel.getProductPrice('p1');
      await viewModel.addProductPrice(ProductPriceParam(
        productId: 'p1',
        unitId: 'u1',
        customerType: 'WHOLESALE',
        price: 18.5,
      ));
      expect(viewModel.state.value.completed, isNotNull);

      repo.throws = const NetworkException(message: 'offline');
      await viewModel.addProductPrice(ProductPriceParam(
        productId: 'p1',
        unitId: 'u1',
        customerType: 'RETAIL',
        price: 20,
      ));

      expect(viewModel.state.value.error, isNotNull);
      expect(viewModel.state.value.completed, isNull);
      expect(viewModel.state.value.loading, isFalse);
      expect(viewModel.state.value.items, hasLength(1));
    });
  });
}
