import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
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
    return Supplier(
        id: '1',
        name: param.name,
        address: param.address,
        phone: param.phone,
        taxId: param.taxId);
  }

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

  @override
  Future<Supplier> updateSupplierById(String supplierId, SupplierParam param) =>
      throw UnimplementedError();

  @override
  Future<Supplier> removeSupplierById(String supplierId) =>
      throw UnimplementedError();
}

SupplierParam buildParam() {
  return SupplierParam(
      name: 'บริษัทยา จำกัด',
      address: 'กรุงเทพฯ',
      phone: '021234567',
      taxId: '0105551234567');
}

SupplierAddViewModel buildViewModel(SupplierRepository repo) {
  return SupplierAddViewModel(
    supplierRepo: repo,
  );
}

void main() {
  test('initial state is not saving', () {
    final vm = buildViewModel(FakeSupplierRepository());

    expect(vm.state.value.saving, isFalse);
  });

  test('a successful save emits the supplier once', () async {
    final repo = FakeSupplierRepository();
    final vm = buildViewModel(repo);
    final created = <Supplier>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createSupplier(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(created.single.name, 'บริษัทยา จำกัด');
    expect(errors, isEmpty);
    expect(repo.createdParam?.taxId, '0105551234567');
  });

  test('a failure emits on the error channel and nothing on created', () async {
    final vm = buildViewModel(
      FakeSupplierRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final created = <Supplier>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createSupplier(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(errors, hasLength(1));
    expect(created, isEmpty);
  });

  test('an outcome is delivered once, with nothing to clear', () async {
    final vm = buildViewModel(FakeSupplierRepository());
    final created = <Supplier>[];
    vm.created.listen(created.add);

    await vm.createSupplier(buildParam());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1),
        reason: 'the old shape needed consumeCreated to stop it repeating');
  });

  test('a second save while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeSupplierRepository());
    final created = <Supplier>[];
    vm.created.listen(created.add);

    final first = vm.createSupplier(buildParam());
    await vm.createSupplier(buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1));
  });
}
