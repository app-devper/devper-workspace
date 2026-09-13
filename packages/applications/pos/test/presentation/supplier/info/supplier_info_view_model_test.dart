import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_info_use_case.dart';
import 'package:pos/presentation/supplier/info/supplier_info_view_model.dart';

class FakeSupplierRepository implements SupplierRepository {
  final Supplier? info;
  final Object? throws;
  SupplierParam? updatedInfoParam;

  FakeSupplierRepository({this.info, this.throws});

  @override
  Future<Supplier> getSupplierInfo() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return info ?? buildSupplier('1');
  }

  @override
  Future<Supplier> updateSupplierInfo(SupplierParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    updatedInfoParam = param;
    return Supplier(
        id: '1',
        name: param.name,
        address: param.address,
        phone: param.phone,
        taxId: param.taxId);
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) =>
      throw UnimplementedError();

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

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) =>
      throw UnimplementedError();

  @override
  Future<Supplier> removeSupplierById(String supplierId) =>
      throw UnimplementedError();
}

Supplier buildSupplier(String id) {
  return Supplier(id: id, name: 'name-$id', address: '', phone: '', taxId: '');
}

SupplierParam buildParam() {
  return SupplierParam(
      name: 'ร้านยาใหม่', address: 'เชียงใหม่', phone: '053123456', taxId: '');
}

SupplierInfoViewModel buildViewModel(SupplierRepository repo) {
  return SupplierInfoViewModel(
    getSupplierInfoUseCase: GetSupplierInfoUseCase(supplierRepo: repo),
    updateSupplierInfoUseCase: UpdateSupplierInfoUseCase(supplierRepo: repo),
  );
}

void main() {
  test('getSupplierInfo populates the supplier', () async {
    final vm = buildViewModel(FakeSupplierRepository(info: buildSupplier('5')));

    await vm.getSupplierInfo();

    expect(vm.state.value.supplier?.id, '5',
        reason: 'the form renders this, so it belongs in state');
  });

  test('a failed load emits an error and leaves the form empty', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final errors = <String>[];
    vm.errors.listen(errors.add);

    await vm.getSupplierInfo();
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.supplier, isNull);
    expect(errors, hasLength(1));
  });

  test('a save emits the updated record once', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);
    final updated = <Supplier>[];
    vm.updated.listen(updated.add);

    await vm.updateSupplierInfo(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(updated.single.name, 'ร้านยาใหม่');
    expect(repo.updatedInfoParam?.address, 'เชียงใหม่');
  });

  test('a failed save emits an error and no outcome', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final updated = <Supplier>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateSupplierInfo(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(updated, isEmpty);
    expect(errors, hasLength(1));
  });

  test('the outcome is delivered once, with nothing to clear', () async {
    final vm = buildViewModel(FakeSupplierRepository());
    final updated = <Supplier>[];
    vm.updated.listen(updated.add);

    await vm.updateSupplierInfo(buildParam());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(updated, hasLength(1));
  });
}
