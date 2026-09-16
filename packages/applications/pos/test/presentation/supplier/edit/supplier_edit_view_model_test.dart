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
  Future<Supplier> updateSupplierById(
      String supplierId, SupplierParam param) async {
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
  Future<Supplier> createSupplier(SupplierParam param) =>
      throw UnimplementedError();

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) =>
      throw UnimplementedError();

  @override
  Future<Supplier> getSupplierInfo() => throw UnimplementedError();

  @override
  Future<List<Supplier>> getSuppliers() => throw UnimplementedError();

  @override
  Future<List<Supplier>> getLocalSuppliers() => throw UnimplementedError();

  @override
  Future<Supplier> getSupplierById(String supplierId) =>
      throw UnimplementedError();

  @override
  Future<Supplier?> getLocalSupplierById(String supplierId) =>
      throw UnimplementedError();
}

Supplier buildSupplier(String id) {
  return Supplier(id: id, name: 'name-$id', address: '', phone: '', taxId: '');
}

SupplierParam buildParam() {
  return SupplierParam(
      name: 'บริษัทยา จำกัด', address: '', phone: '', taxId: '');
}

SupplierEditViewModel buildViewModel(SupplierRepository repo) {
  return SupplierEditViewModel(
    updateSupplierByIdUseCase: UpdateSupplierByIdUseCase(supplierRepo: repo),
    removeSupplierByIdUseCase: RemoveSupplierByIdUseCase(supplierRepo: repo),
  );
}

void main() {
  test('a save emits the updated record once', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);
    final updated = <Supplier>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateSupplierById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(updated.single.id, '7');
    expect(errors, isEmpty);
    expect(vm.state.value.busy, isFalse);
    expect(repo.updatedSupplierId, '7');
  });

  test('a delete emits on its own channel, not the save one', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);
    final updated = <Supplier>[];
    final removed = <Supplier>[];
    vm.updated.listen(updated.add);
    vm.removed.listen(removed.add);

    await vm.removeSupplierById('9');
    await Future<void>.delayed(Duration.zero);

    expect(removed.single.id, '9');
    expect(updated, isEmpty,
        reason: 'the two outcomes cannot be mistaken for each other');
    expect(repo.removedSupplierId, '9');
  });

  test('a save then a delete deliver both, in order', () async {
    final vm = buildViewModel(FakeSupplierRepository());
    final seen = <String>[];
    vm.updated.listen((e) => seen.add('updated:${e.id}'));
    vm.removed.listen((e) => seen.add('removed:${e.id}'));

    await vm.updateSupplierById('7', buildParam());
    await vm.removeSupplierById('9');
    await Future<void>.delayed(Duration.zero);

    expect(seen, ['updated:7', 'removed:9'],
        reason: 'the old shape had one slot, so the second replaced the first');
  });

  test('a failure emits an error and no outcome', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final updated = <Supplier>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateSupplierById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(updated, isEmpty);
    expect(vm.state.value.busy, isFalse);
  });

  test('a second command while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeSupplierRepository());
    final updated = <Supplier>[];
    vm.updated.listen(updated.add);

    final first = vm.updateSupplierById('7', buildParam());
    await vm.updateSupplierById('7', buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(updated, hasLength(1));
  });
}
