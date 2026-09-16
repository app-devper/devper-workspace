import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/add_product_unit_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_unit_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_unit_by_id_use_case.dart';
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
  group('the three commands each emit their result', () {
    test('addProductUnit emits', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);
      final completed = <ProductUnit>[];
      vm.completed.listen(completed.add);

      await vm.addProductUnit(buildParam());
      await Future<void>.delayed(Duration.zero);

      expect(completed.single.id, 'new-unit');
      expect(vm.state.value.loading, isFalse);
      expect(repo.addedProductId, 'product-1');
    });

    test('updateProductUnitById emits', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);
      final completed = <ProductUnit>[];
      vm.completed.listen(completed.add);

      await vm.updateProductUnitById('unit-7', buildParam());
      await Future<void>.delayed(Duration.zero);

      expect(completed.single.id, 'unit-7');
      expect(repo.updatedUnitId, 'unit-7');
    });

    test('removeProductUnitById emits', () async {
      final repo = FakeProductRepository();
      final vm = buildViewModel(repo);
      final completed = <ProductUnit>[];
      vm.completed.listen(completed.add);

      await vm.removeProductUnitById('unit-9');
      await Future<void>.delayed(Duration.zero);

      expect(completed.single.id, 'unit-9');
      expect(repo.removedUnitId, 'unit-9');
    });

    test('two commands deliver two results, in order', () async {
      final vm = buildViewModel(FakeProductRepository());
      final completed = <ProductUnit>[];
      vm.completed.listen(completed.add);

      await vm.addProductUnit(buildParam());
      await vm.removeProductUnitById('unit-9');
      await Future<void>.delayed(Duration.zero);

      expect(completed.map((e) => e.id), ['new-unit', 'unit-9'],
          reason:
              'each result reaches the view rather than replacing the last');
    });
  });

  test('getProductUnit fills items and emits nothing', () async {
    final vm = buildViewModel(
      FakeProductRepository(units: [buildUnit('unit-1'), buildUnit('unit-2')]),
    );
    final completed = <ProductUnit>[];
    vm.completed.listen(completed.add);

    await vm.getProductUnit('product-1');
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.items, hasLength(2));
    expect(completed, isEmpty,
        reason: 'loading the list is not a command with a result');
  });

  test('a failure emits an error and no completion', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    final completed = <ProductUnit>[];
    final errors = <String>[];
    vm.completed.listen(completed.add);
    vm.errors.listen(errors.add);

    await vm.addProductUnit(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(completed, isEmpty);
    expect(vm.state.value.loading, isFalse);
  });

  test('a failed list load leaves the items empty and reports', () async {
    final vm = buildViewModel(
      FakeProductRepository(throws: const NetworkException(message: 'offline')),
    );
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getProductUnit('product-1');
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.items, isEmpty);
    expect(errors, hasLength(1));
  });

  test('a second command while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeProductRepository());
    final completed = <ProductUnit>[];
    vm.completed.listen(completed.add);

    final first = vm.addProductUnit(buildParam());
    await vm.addProductUnit(buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(completed, hasLength(1));
  });
}
