import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_lot_quantity_by_lot_id_use_case.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_view_model.dart';

ProductLot lot(String id, {int quantity = 10}) {
  return ProductLot(
    id: id,
    productId: 'p1',
    lotNumber: 'L1',
    costPrice: 12,
    quantity: quantity,
    expireDate: '2027-01-01T00:00:00Z',
    notify: false,
  );
}

Product product(String id, String name) {
  return Product(
    id: id,
    name: name,
    status: 'ACTIVE',
    category: 'general',
    createdDate: '2026-01-01T00:00:00Z',
    units: const [],
    prices: const [],
    stocks: const [],
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.localProduct, this.throws});

  final Product? localProduct;
  final Object? throws;
  final List<String> calls = [];

  @override
  Future<ProductLot> updateProductLotQuantityByLotId(
      String lotId, UpdateProductLotQuantityParam param) async {
    calls.add('quantity:$lotId=${param.quantity}');
    final error = throws;
    if (error != null) throw error;
    return lot(lotId, quantity: param.quantity);
  }

  @override
  Future<Product?> getLocalProductById(String productId) async {
    calls.add('product:$productId');
    return localProduct;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductLotEditViewModel buildViewModel(FakeProductRepository repo) {
  return ProductLotEditViewModel(
    updateProductLotQuantityByLotIdUseCase:
        UpdateProductLotQuantityByLotIdUseCase(productRepo: repo),
    getLocalProductByIdUseCase: GetLocalProductByIdUseCase(productRepo: repo),
  );
}

void main() {
  test('getProductLot puts the chosen lot on screen without a round trip',
      () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);

    viewModel.getProductLot(lot('lot-1', quantity: 6));

    expect(viewModel.state.value.loaded?.id, 'lot-1');
    expect(viewModel.state.value.loaded?.quantity, 6);
    expect(repo.calls, isEmpty);
  });

  test('updateProductLot writes the count then attaches the product',
      () async {
    final repo = FakeProductRepository(localProduct: product('p1', 'ยาแก้ไข้'));
    final viewModel = buildViewModel(repo);

    await viewModel.updateProductLot(
        'lot-1', UpdateProductLotQuantityParam(quantity: 3));

    // The product lookup has to follow the write: the screen shows the lot
    // with its product name once the count is saved.
    expect(repo.calls, ['quantity:lot-1=3', 'product:p1']);
    expect(viewModel.state.value.updated?.quantity, 3);
    expect(viewModel.state.value.updated?.product?.name, 'ยาแก้ไข้');
    expect(viewModel.state.value.loading, isFalse);
  });

  test('zero is a legitimate count', () async {
    final repo = FakeProductRepository(localProduct: product('p1', 'ยาแก้ไข้'));
    final viewModel = buildViewModel(repo);

    await viewModel.updateProductLot(
        'lot-1', UpdateProductLotQuantityParam(quantity: 0));

    expect(viewModel.state.value.updated?.quantity, 0);
    expect(viewModel.state.value.error, isNull);
  });

  test('a rejected write marks nothing as updated and never looks up the product',
      () async {
    final repo = FakeProductRepository(
      throws: const ValidationException(message: 'invalid', code: 'VA-400'),
    );
    final viewModel = buildViewModel(repo);

    await viewModel.updateProductLot(
        'lot-1', UpdateProductLotQuantityParam(quantity: -5));

    expect(repo.calls, ['quantity:lot-1=-5']);
    expect(viewModel.state.value.updated, isNull);
    expect(viewModel.state.value.error, isNotNull);
  });

  test('the one-shot results clear when consumed', () async {
    final repo = FakeProductRepository(localProduct: product('p1', 'ยาแก้ไข้'));
    final viewModel = buildViewModel(repo);

    viewModel.getProductLot(lot('lot-1'));
    await viewModel.updateProductLot(
        'lot-1', UpdateProductLotQuantityParam(quantity: 2));

    viewModel.consumeLoaded();
    viewModel.consumeUpdated();

    expect(viewModel.state.value.loaded, isNull);
    expect(viewModel.state.value.updated, isNull);
  });
}
