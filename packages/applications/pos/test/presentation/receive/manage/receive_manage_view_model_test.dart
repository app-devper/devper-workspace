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
import 'package:pos/presentation/receive/manage/receive_manage_view_model.dart';

class FakeReceiveRepository implements ReceiveRepository {
  final Receive? receive;
  final List<ReceiveItem> items;
  final Object? throws;

  /// Fails only the line fetch, so a test can break it without breaking the
  /// document load that calls it.
  final Object? itemsThrows;

  FakeReceiveRepository(
      {this.receive, this.items = const [], this.throws, this.itemsThrows});

  Receive get _result => receive ?? buildReceive('r1');

  @override
  Future<Receive> getReceiveById(String receiveId) async =>
      _maybeThrow(_result);

  @override
  Future<List<ReceiveItem>> getReceiveItemsById(String receiveId) async {
    final error = itemsThrows;
    if (error != null) {
      throw error;
    }
    return _maybeThrow(items);
  }

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
  Object? itemsThrow,
  Object? suppliersThrows,
}) {
  final ProductRepository productRepo = FakeProductRepository();
  final SupplierRepository supplierRepo = FakeSupplierRepository(
      suppliers: suppliers, remoteThrows: suppliersThrows);
  final ReceiveRepository receiveRepo = FakeReceiveRepository(
      receive: receive, items: items, throws: throws, itemsThrows: itemsThrow);
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
  test('loads the document, its suppliers and its lines', () async {
    final vm = buildViewModel(
      receive: buildReceive('7'),
      items: [buildReceiveItem('7')],
      suppliers: [
        Supplier(id: 's1', name: 'ACME', address: '', phone: '', taxId: '')
      ],
    );
    final loaded = <Receive>[];
    vm.loaded.listen(loaded.add);

    await vm.getReceiveById('7');
    await _pump();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.receive?.id, '7');
    expect(vm.state.value.receiveSuppliers, hasLength(1));
    expect(vm.state.value.items, hasLength(1));
    expect(vm.state.value.itemsReady, isTrue);
    expect(loaded.single.id, '7',
        reason: 'the form seeds its fields from this');
  });

  test('creating a new one fetches the suppliers and nothing else', () async {
    final vm = buildViewModel(suppliers: [
      Supplier(id: 's1', name: 'ACME', address: '', phone: '', taxId: '')
    ]);
    final loaded = <Receive>[];
    vm.loaded.listen(loaded.add);

    await vm.getReceiveById(null);
    await _pump();

    expect(vm.state.value.receive, isNull);
    expect(vm.state.value.receiveSuppliers, hasLength(1));
    expect(loaded, isEmpty, reason: 'there is no document to seed the form');
  });

  test(
      'a failed line load is reported, not swallowed by the load that '
      'wraps it', () async {
    final vm = buildViewModel(
        receive: buildReceive('7'),
        itemsThrow: const NetworkException(message: 'offline'));
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getReceiveById('7');
    await _pump();

    expect(vm.state.value.receive?.id, '7');
    expect(errors, hasLength(1),
        reason: 'the outer success used to overwrite this failure, leaving '
            'an empty list of lines and no message');
    expect(vm.state.value.itemsReady, isFalse);
  });

  test('creating announces the new document and makes it editable', () async {
    final vm = buildViewModel(receive: buildReceive('9'));
    final created = <Receive>[];
    vm.created.listen(created.add);

    await vm.createReceive(ReceiveParam(supplierId: 's1', reference: 'ref'));
    await _pump();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.receive?.id, '9');
    expect(vm.state.value.itemsReady, isTrue,
        reason: 'a document with no lines yet can still be saved');
    expect(created.single.id, '9');
  });

  test('saving announces the document and reloads its lines', () async {
    final vm = buildViewModel(
        receive: buildReceive('9'), items: [buildReceiveItem('9')]);
    final updated = <Receive>[];
    vm.updated.listen(updated.add);

    await vm.getReceiveById('9');
    final saved = await vm.updateReceiveById(
        '9',
        UpdateReceiveParam(
            supplierId: 's1', reference: 'ref', totalCost: 0, items: []));
    await _pump();

    expect(saved, isTrue);
    expect(updated.single.id, '9');
    expect(vm.state.value.items, hasLength(1));
    expect(vm.state.value.totalCost, 20);
  });

  test('deleting announces the removed document so the screen can pop with it',
      () async {
    final vm = buildViewModel(receive: buildReceive('9'));
    final removed = <Receive>[];
    vm.removed.listen(removed.add);

    await vm.removeReceiveById('9');
    await _pump();

    expect(removed.single.id, '9');
    expect(vm.state.value.loading, isFalse);
  });

  test('importing announces the document it got back', () async {
    final vm = buildViewModel();
    final updated = <Receive>[];
    vm.updated.listen(updated.add);

    await vm.getReceiveById('r1');
    await vm.importReceive('r1');
    await _pump();

    expect(updated.single.id, 'r1');
  });

  test('lines that failed to load block a save that would empty the document',
      () async {
    final vm =
        buildViewModel(throws: const NetworkException(message: 'offline'));
    final errors = <String>[];
    final updated = <Receive>[];
    vm.errors.listen(errors.add);
    vm.updated.listen(updated.add);

    await vm.getReceiveItemsById('r1');
    await _pump();

    expect(errors, hasLength(1));
    expect(vm.state.value.itemsReady, isFalse);

    final saved = await vm.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1', reference: '', totalCost: 0, items: []));
    await _pump();

    expect(saved, isFalse);
    expect(updated, isEmpty);
  });

  test('an imported document cannot be edited or imported again', () async {
    final vm = buildViewModel(
        receive: Receive(
            id: 'r1',
            supplierId: 's1',
            code: 'RC1',
            reference: '',
            totalCost: 0,
            createdDate: '',
            status: 'IMPORTED'));
    final updated = <Receive>[];
    vm.updated.listen(updated.add);

    await vm.getReceiveById('r1');
    final saved = await vm.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1', reference: '', totalCost: 0, items: []));
    await vm.importReceive('r1');
    await _pump();

    expect(saved, isFalse);
    expect(updated, isEmpty);
  });

  test('a failed load is reported and stops the spinner', () async {
    final vm =
        buildViewModel(throws: const NetworkException(message: 'offline'));
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getReceiveById('7');
    await _pump();

    expect(errors, hasLength(1));
    expect(vm.state.value.loading, isFalse);
  });

  test('refreshing the supplier list replaces the picker options', () async {
    final vm = buildViewModel(suppliers: [
      Supplier(id: 's1', name: 'ACME', address: '', phone: '', taxId: '')
    ]);

    await vm.getSuppliers();

    expect(vm.state.value.receiveSuppliers, hasLength(1),
        reason: 'this used to arrive as an event the page had to copy');
  });

  test('a failed supplier refresh is reported and keeps the old options',
      () async {
    final vm = buildViewModel(
      suppliers: [
        Supplier(id: 's1', name: 'ACME', address: '', phone: '', taxId: '')
      ],
      suppliersThrows: const NetworkException(message: 'offline'),
    );
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getReceiveById(null);
    await vm.getSuppliers();
    await _pump();

    expect(errors, hasLength(1));
    expect(vm.state.value.receiveSuppliers, hasLength(1),
        reason: 'the picker must not empty itself because a refresh failed');
  });

  test('a second command is refused while one is in flight', () async {
    final vm = buildViewModel(receive: buildReceive('9'));
    final removed = <Receive>[];
    vm.removed.listen(removed.add);

    final creating =
        vm.createReceive(ReceiveParam(supplierId: 's1', reference: 'ref'));
    await vm.removeReceiveById('9');
    await creating;
    await _pump();

    expect(removed, isEmpty);
  });
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);
