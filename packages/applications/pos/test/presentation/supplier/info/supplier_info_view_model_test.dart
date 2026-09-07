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
    return Supplier(id: '1', name: param.name, address: param.address, phone: param.phone, taxId: param.taxId);
  }

  @override
  Future<Supplier> createSupplier(SupplierParam param) => throw UnimplementedError();

  @override
  Future<List<Supplier>> getSuppliers() => throw UnimplementedError();

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

SupplierParam buildParam() {
  return SupplierParam(name: 'ร้านยาใหม่', address: 'เชียงใหม่', phone: '053123456', taxId: '');
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

    expect(vm.state.value.supplier?.id, '5');
  });

  test('getSupplierInfo failure leaves state untouched', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getSupplierInfo();

    expect(vm.state.value.supplier, isNull);
    expect(vm.state.value.error, isNull);
  });

  test('updateSupplierInfo sets updated on success', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);

    await vm.updateSupplierInfo(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.updated?.name, 'ร้านยาใหม่');
    expect(repo.updatedInfoParam?.address, 'เชียงใหม่');
  });

  test('updateSupplierInfo maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateSupplierInfo(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('consumeUpdated clears the updated result', () async {
    final vm = buildViewModel(FakeSupplierRepository());

    await vm.updateSupplierInfo(buildParam());
    expect(vm.state.value.updated, isNotNull);

    vm.consumeUpdated();

    expect(vm.state.value.updated, isNull);
  });
}
