import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/add_product_unit_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_unit_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_unit_by_id_use_case.dart';
import 'package:pos/presentation/product/unit/product_unit_state.dart';
import 'package:pos/presentation/product/unit/product_unit_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final Object? throws;
  final List<ProductUnit> units;

  String? addedProductId;
  String? updatedUnitId;
  String? removedUnitId;

  FakeProductRepository({this.throws, this.units = const []});

  @override
  Future<ProductUnit> addProductUnit(ProductUnitParam param) async {
    _maybeThrow();
    addedProductId = param.productId;
    return buildUnit('new-unit');
  }

  @override
  Future<ProductUnit> updateProductUnitById(
      String id, ProductUnitParam param) async {
    _maybeThrow();
    updatedUnitId = id;
    return buildUnit(id);
  }

  @override
  Future<ProductUnit> removeProductUnitById(String id) async {
    _maybeThrow();
    removedUnitId = id;
    return buildUnit(id);
  }

  @override
  Future<List<ProductUnit>> getProductUnitsByProductId(String productId) async {
    _maybeThrow();
    return units;
  }

  void _maybeThrow() {
    final error = throws;
    if (error != null) {
      throw error;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductUnit buildUnit(String id) {
  return ProductUnit(
    id: id,
    productId: 'product-1',
    costPrice: 5,
    unit: 'เม็ด',
    size: 1,
    barcode: '8850001',
    volume: 0,
    volumeUnit: '',
  );
}

ProductUnitParam buildParam() {
  return ProductUnitParam(
    productId: 'product-1',
    unit: 'แผง',
    costPrice: 50,
    price: 80,
    size: 10,
    barcode: '8850002',
    volume: 0,
    volumeUnit: '',
  );
}

ProductUnitViewModel buildViewModel(ProductRepository repo) {
  return ProductUnitViewModel(
    addProductUnitUseCase: AddProductUnitUseCase(productRepo: repo),
    updateProductUnitByIdUseCase:
        UpdateProductUnitByIdUseCase(productRepo: repo),
    removeProductUnitByIdUseCase:
        RemoveProductUnitByIdUseCase(productRepo: repo),
    getProductUnitsByProductIdUseCase:
        GetProductUnitsByProductIdUseCase(productRepo: repo),
  );
}

void main() {
  group('the three commands share one completion slot', () {
    test('addProductUnit completes', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);

      await vm.addProductUnit(buildParam());

      expect(vm.state.value.task, isA<ProductUnitCompleted>());
      expect(vm.state.value.completed?.id, 'new-unit');
      expect(vm.state.value.loading, isFalse);
      expect(repo.addedProductId, 'product-1');
    });

    test('updateProductUnitById completes', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);

      await vm.updateProductUnitById('unit-7', buildParam());

      expect(vm.state.value.completed?.id, 'unit-7');
      expect(repo.updatedUnitId, 'unit-7');
    });

    test('removeProductUnitById completes', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);

      await vm.removeProductUnitById('unit-9');

      expect(vm.state.value.completed?.id, 'unit-9');
      expect(repo.removedUnitId, 'unit-9');
    });

    test('a later command replaces the earlier result', () async {
      final vm = buildViewModel(FakeProductRepository());

      await vm.addProductUnit(buildParam());
      expect(vm.state.value.completed?.id, 'new-unit');

      await vm.removeProductUnitById('unit-9');

      expect(vm.state.value.completed?.id, 'unit-9',
          reason: 'one slot, so the previous result cannot linger');
    });
  });

  test('getProductUnit fills items and leaves the task idle', () async {
    final vm = buildViewModel(
      FakeProductRepository(units: [buildUnit('unit-1'), buildUnit('unit-2')]),
    );

    await vm.getProductUnit('product-1');

    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.task, isA<ProductUnitIdle>(),
        reason: 'loading the list is not a command with a result');
    expect(vm.state.value.completed, isNull);
  });

  test('a failure leaves no completion behind', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.addProductUnit(buildParam());

    expect(vm.state.value.task, isA<ProductUnitFailed>());
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.completed, isNull);
    expect(vm.state.value.loading, isFalse);
  });

  test('a failed list load keeps the items already on screen', () async {
    final good = FakeProductRepository(units: [buildUnit('unit-1')]);
    final vm = buildViewModel(good);
    await vm.getProductUnit('product-1');
    expect(vm.state.value.items, hasLength(1));

    final failing = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    await failing.getProductUnit('product-1');

    expect(failing.state.value.items, isEmpty);
    expect(failing.state.value.error, isNotNull);
  });

  test('consumeError and consumeCompleted each clear only their own state',
      () async {
    final vm = buildViewModel(FakeProductRepository());

    await vm.addProductUnit(buildParam());
    vm.consumeError();
    expect(vm.state.value.completed, isNotNull,
        reason: 'consuming an error must not discard an unread result');

    vm.consumeCompleted();
    expect(vm.state.value.task, isA<ProductUnitIdle>());
  });
}
