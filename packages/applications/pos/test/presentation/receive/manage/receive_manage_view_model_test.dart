import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/get_products_use_case.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/create_receive_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_items_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/remove_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/import_receive_use_case.dart';
import 'package:pos/domain/usecase/receive/update_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_local_suppliers_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_suppliers_use_case.dart';
import 'package:pos/presentation/receive/manage/receive_manage_state.dart';
import 'package:pos/presentation/receive/manage/receive_manage_view_model.dart';

class FakeReceiveRepository implements ReceiveRepository {
  final Receive? receive;
  final List<ReceiveItem> items;
  final Object? throws;

  FakeReceiveRepository({this.receive, this.items = const [], this.throws});

  Receive get _result => receive ?? buildReceive('r1');

  @override
  Future<Receive> getReceiveById(String receiveId) async =>
      _maybeThrow(_result);

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async =>
      _maybeThrow(items);

  @override
  Future<Receive> createReceive(ReceiveParam param) async =>
      _maybeThrow(_result);

  @override
  Future<Receive> updateReceiveById(
          String receiveId, UpdateReceiveParam param) async =>
      _maybeThrow(_result);

  @override
  Future<Receive> removeReceiveById(String receiveId) async =>
      _maybeThrow(_result);

  @override
  Future<Receive> importReceiveById(String receiveId) async =>
      _maybeThrow(_result);

  T _maybeThrow<T>(T value) {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeSupplierRepository implements SupplierRepository {
  final List<Supplier> suppliers;

  /// Only the remote fetch fails, so a test can break the supplier list
  /// without breaking the screen's initial load.
  final Object? remoteThrows;

  FakeSupplierRepository({this.suppliers = const [], this.remoteThrows});

  @override
  Future<List<Supplier>> getLocalSuppliers() async => suppliers;

  @override
  Future<List<Supplier>> getSuppliers() async {
    final error = remoteThrows;
    if (error != null) {
      throw error;
    }
    return suppliers;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeProductRepository implements ProductRepository {
  @override
  Future<Product?> getLocalProductById(String id) async => null;
  @override
  Future<List<Product>> getProducts() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Receive buildReceive(String id) {
  return Receive(
      id: id,
      supplierId: 's1',
      code: 'RC-$id',
      reference: 'ref',
      totalCost: 0,
      createdDate: '');
}

ReceiveItem buildReceiveItem(String receiveId) {
  return ReceiveItem(
      id: 'i1',
      receiveId: receiveId,
      productId: 'p1',
      lotId: 'l1',
      costPrice: 10,
      quantity: 2);
}

ReceiveManageViewModel buildViewModel({
  Receive? receive,
  List<ReceiveItem> items = const [],
  List<Supplier> suppliers = const [],
  Object? throws,
  Object? suppliersThrows,
}) {
  final ProductRepository productRepo = FakeProductRepository();
  final SupplierRepository supplierRepo = FakeSupplierRepository(
      suppliers: suppliers, remoteThrows: suppliersThrows);
  final ReceiveRepository receiveRepo =
      FakeReceiveRepository(receive: receive, items: items, throws: throws);
  return ReceiveManageViewModel(
    getReceiveByIdUseCase: GetReceiveByIdUseCase(receiveRepo: receiveRepo),
    createReceiveUseCase: CreateReceiveUseCase(receiveRepo: receiveRepo),
    updateReceiveByIdUseCase:
        UpdateReceiveByIdUseCase(receiveRepo: receiveRepo),
    removeReceiveByIdUseCase:
        RemoveReceiveByIdUseCase(receiveRepo: receiveRepo),
    getReceiveItemsByIdUseCase:
        GetReceiveItemsByIdUseCase(receiveRepo: receiveRepo),
    importReceiveUseCase: ImportReceiveUseCase(receiveRepo: receiveRepo),
    getLocalSuppliersUseCase:
        GetLocalSuppliersUseCase(supplierRepo: supplierRepo),
    getSuppliersUseCase: GetSuppliersUseCase(supplierRepo: supplierRepo),
    getLocalProductByIdUseCase:
        GetLocalProductByIdUseCase(productRepo: productRepo),
    getProductsUseCase: GetProductsUseCase(productRepo: productRepo),
  );
}

void main() {
  test('getReceiveById loads the receive and suppliers', () async {
    final vm = buildViewModel(
      receive: buildReceive('7'),
      suppliers: [
        Supplier(id: 's1', name: 'ACME', address: '', phone: '', taxId: '')
      ],
    );

    await vm.getReceiveById('7');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.receiveLoaded, isTrue);
    expect(vm.state.value.receive?.id, '7');
    expect(vm.state.value.receiveSuppliers, hasLength(1));
  });

  test('getReceiveById with a null id marks loaded without a receive',
      () async {
    final vm = buildViewModel();

    await vm.getReceiveById(null);

    expect(vm.state.value.receiveLoaded, isTrue);
    expect(vm.state.value.receive, isNull);
  });

  test('createReceive sets the created and receive one-shots', () async {
    final vm = buildViewModel(receive: buildReceive('9'));

    await vm.createReceive(ReceiveParam(supplierId: 's1', reference: 'ref'));

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.created?.id, '9');
    expect(vm.state.value.receive?.id, '9');

    vm.consumeCreated();
    expect(vm.state.value.created, isNull);
  });

  test('updateReceiveById sets the updated one-shot', () async {
    final vm = buildViewModel(receive: buildReceive('9'));

    await vm.getReceiveById('9');
    await vm.updateReceiveById(
        '9',
        UpdateReceiveParam(
            supplierId: 's1', reference: 'ref', totalCost: 0, items: []));

    expect(vm.state.value.updated?.id, '9');
  });

  test('removeReceiveById sets the removed one-shot', () async {
    final vm = buildViewModel(receive: buildReceive('9'));

    await vm.removeReceiveById('9');

    expect(vm.state.value.removed?.id, '9');
  });

  test('import receive publishes the returned document', () async {
    final vm = buildViewModel();
    await vm.getReceiveById('r1');
    await vm.importReceive('r1');
    expect(vm.state.value.updated?.id, 'r1');
  });

  test('failed item loading is visible and blocks saving an empty list',
      () async {
    final vm =
        buildViewModel(throws: const NetworkException(message: 'offline'));
    await vm.getReceiveItemsById('r1');
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.itemsReady, isFalse);
    final saved = await vm.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1', reference: '', totalCost: 0, items: []));
    expect(saved, isFalse);
    expect(vm.state.value.updated, isNull);
  });

  test('imported documents cannot be edited or imported again', () async {
    final vm = buildViewModel(
        receive: Receive(
            id: 'r1',
            supplierId: 's1',
            code: 'RC1',
            reference: '',
            totalCost: 0,
            createdDate: '',
            status: 'IMPORTED'));
    await vm.getReceiveById('r1');
    final saved = await vm.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1', reference: '', totalCost: 0, items: []));
    await vm.importReceive('r1');
    expect(saved, isFalse);
    expect(vm.state.value.updated, isNull);
  });

  test('getReceiveById maps a typed exception to state.error', () async {
    final vm =
        buildViewModel(throws: const NetworkException(message: 'offline'));

    await vm.getReceiveById('7');

    expect(vm.state.value.error, isNotNull);
  });

  group('one command result at a time', () {
    test('saving after creating drops the stale created result', () async {
      final vm = buildViewModel(receive: buildReceive('9'));

      await vm.createReceive(ReceiveParam(supplierId: 's1', reference: 'ref'));
      expect(vm.state.value.created, isNotNull);

      await vm.updateReceiveById(
          '9',
          UpdateReceiveParam(
              supplierId: 's1', reference: 'ref', totalCost: 0, items: []));

      expect(vm.state.value.updated, isNotNull);
      expect(vm.state.value.created, isNull,
          reason: 'the create result must not outlive the save that follows');
      expect(vm.state.value.task, isA<ReceiveUpdated>());
    });

    test('deleting drops a stale save result', () async {
      final vm = buildViewModel(receive: buildReceive('9'));

      await vm.getReceiveById('9');
      await vm.updateReceiveById(
          '9',
          UpdateReceiveParam(
              supplierId: 's1', reference: 'ref', totalCost: 0, items: []));
      expect(vm.state.value.updated, isNotNull);

      await vm.removeReceiveById('9');

      expect(vm.state.value.removed, isNotNull);
      expect(vm.state.value.updated, isNull);
    });

    test('a failure leaves no command result behind', () async {
      final vm = buildViewModel(
        receive: buildReceive('9'),
        suppliersThrows: const NetworkException(message: 'offline'),
      );

      await vm.createReceive(ReceiveParam(supplierId: 's1', reference: 'ref'));
      expect(vm.state.value.created, isNotNull);

      await vm.getSuppliers();

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.created, isNull);
      expect(vm.state.value.loading, isFalse);
    });
  });
}
