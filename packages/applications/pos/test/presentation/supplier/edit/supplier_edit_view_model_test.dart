import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/supplier/remove_supplier_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_by_id_use_case.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_view_model.dart';

class FakeSupplierRepository implements SupplierRepository {
  final Object? throws;
  String? updatedSupplierId;
  String? removedSupplierId;

  FakeSupplierRepository({this.throws});

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    updatedSupplierId = supplierId;
    return buildSupplier(supplierId);
  }

  @override
  Future<Supplier> removeSupplierById(String supplierId) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    removedSupplierId = supplierId;
    return buildSupplier(supplierId);
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> getSupplierInfo() => throw UnimplementedError();

  @override
  Future<List<Supplier>> getSuppliers() => throw UnimplementedError();

  @override
  Future<List<Supplier>> getLocalSuppliers() => throw UnimplementedError();

  @override
  Future<Supplier> getSupplierById(String supplierId) => throw UnimplementedError();

  @override
  Future<Supplier?> getLocalSupplierById(String supplierId) => throw UnimplementedError();
}

Supplier buildSupplier(String id) {
  return Supplier(id: id, name: 'name-$id', address: '', phone: '', taxId: '');
}

SupplierParam buildParam() {
  return SupplierParam(name: 'บริษัทยา จำกัด', address: '', phone: '', taxId: '');
}

SupplierEditViewModel buildViewModel(SupplierRepository repo) {
  return SupplierEditViewModel(
    updateSupplierByIdUseCase: UpdateSupplierByIdUseCase(supplierRepo: repo),
    removeSupplierByIdUseCase: RemoveSupplierByIdUseCase(supplierRepo: repo),
  );
}

void main() {
  test('updateSupplierById sets updated on success', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);

    await vm.updateSupplierById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated?.id, '7');
    expect(repo.updatedSupplierId, '7');
    expect(vm.state.value.error, isNull);
  });

  test('updateSupplierById maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateSupplierById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('removeSupplierById sets removed on success', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);

    await vm.removeSupplierById('9');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.removed?.id, '9');
    expect(repo.removedSupplierId, '9');
  });

  test('consumeUpdated clears the updated result', () async {
    final vm = buildViewModel(FakeSupplierRepository());

    await vm.updateSupplierById('7', buildParam());
    expect(vm.state.value.updated, isNotNull);

    vm.consumeUpdated();

    expect(vm.state.value.updated, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateSupplierById('7', buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
