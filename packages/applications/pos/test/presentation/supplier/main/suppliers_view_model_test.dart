import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/main/suppliers_view_model.dart';

class FakeSupplierRepository implements SupplierRepository {
  final List<Supplier> suppliers;
  final Object? throws;

  FakeSupplierRepository({this.suppliers = const [], this.throws});

  @override
  Future<List<Supplier>> getSuppliers() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return suppliers;
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> getSupplierInfo() => throw UnimplementedError();

  @override
  Future<List<Supplier>> getLocalSuppliers() => throw UnimplementedError();

  @override
  Future<Supplier> getSupplierById(String supplierId) => throw UnimplementedError();

  @override
  Future<Supplier?> getLocalSupplierById(String supplierId) => throw UnimplementedError();

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> removeSupplierById(String supplierId) => throw UnimplementedError();
}

Supplier buildSupplier(String id) {
  return Supplier(id: id, name: 'name-$id', address: '', phone: '', taxId: '');
}

void main() {
  test('getSuppliers populates items and clears loading', () async {
    final vm = SuppliersViewModel(
      supplierRepo: FakeSupplierRepository(suppliers: [buildSupplier('1'), buildSupplier('2')]),
    );

    await vm.getSuppliers();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.error, isNull);
  });

  test('getSuppliers maps a typed exception to state.error', () async {
    final vm = SuppliersViewModel(
      supplierRepo: FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getSuppliers();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.items, isEmpty);
  });

  test('consumeError clears the error', () async {
    final vm = SuppliersViewModel(
      supplierRepo: FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getSuppliers();
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
