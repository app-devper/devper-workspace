import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/supplier/create_supplier_use_case.dart';
import 'package:pos/presentation/supplier/add/supplier_add_view_model.dart';

class FakeSupplierRepository implements SupplierRepository {
  final Object? throws;
  SupplierParam? createdParam;

  FakeSupplierRepository({this.throws});

  @override
  Future<Supplier> createSupplier(SupplierParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    createdParam = param;
    return Supplier(id: '1', name: param.name, address: param.address, phone: param.phone, taxId: param.taxId);
  }

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

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) => throw UnimplementedError();

  @override
  Future<Supplier> removeSupplierById(String supplierId) => throw UnimplementedError();
}

SupplierParam buildParam() {
  return SupplierParam(name: 'บริษัทยา จำกัด', address: 'กรุงเทพฯ', phone: '021234567', taxId: '0105551234567');
}

SupplierAddViewModel buildViewModel(SupplierRepository repo) {
  return SupplierAddViewModel(
    createSupplierUseCase: CreateSupplierUseCase(supplierRepo: repo),
  );
}

void main() {
  test('initial state is not saving with no result', () {
    final vm = buildViewModel(FakeSupplierRepository());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNull);
  });

  test('createSupplier sets created on success', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);

    await vm.createSupplier(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created?.name, 'บริษัทยา จำกัด');
    expect(repo.createdParam?.taxId, '0105551234567');
    expect(vm.state.value.error, isNull);
  });

  test('createSupplier maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createSupplier(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('consumeCreated clears the created result', () async {
    final vm = buildViewModel(FakeSupplierRepository());

    await vm.createSupplier(buildParam());
    expect(vm.state.value.created, isNotNull);

    vm.consumeCreated();

    expect(vm.state.value.created, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createSupplier(buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
