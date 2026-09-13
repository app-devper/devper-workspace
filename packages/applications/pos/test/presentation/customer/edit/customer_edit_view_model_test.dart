import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/usecase/customer/remove_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/update_customer_by_id_use_case.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';

class FakeCustomerRepository implements CustomerRepository {
  final Object? throws;
  String? updatedCustomerId;
  String? removedCustomerId;

  FakeCustomerRepository({this.throws});

  @override
  Future<Customer> updateCustomerById(
      String customerId, CustomerParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    updatedCustomerId = customerId;
    return buildCustomer(customerId);
  }

  @override
  Future<Customer> removeCustomerById(String customerId) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    removedCustomerId = customerId;
    return buildCustomer(customerId);
  }

  @override
  Future<Customer> createCustomer(CustomerParam param) =>
      throw UnimplementedError();

  @override
  Future<List<Customer>> getCustomers() => throw UnimplementedError();

  @override
  Future<List<Customer>> getLocalCustomers() => throw UnimplementedError();

  @override
  Future<Customer> getCustomerById(String customerId) =>
      throw UnimplementedError();

  @override
  Future<Customer> getCustomerByCode(String customerCode) =>
      throw UnimplementedError();
}

Customer buildCustomer(String id) {
  return Customer(
    id: id,
    code: 'code-$id',
    name: 'name-$id',
    address: '',
    phone: '',
    email: '',
    status: 'ACTIVE',
    type: 'GENERAL',
  );
}

CustomerParam buildParam() {
  return CustomerParam(
      name: 'สมหญิง',
      address: '',
      phone: '',
      email: '',
      customerType: 'GENERAL');
}

CustomerEditViewModel buildViewModel(CustomerRepository repo) {
  return CustomerEditViewModel(
    updateCustomerByIdUseCase: UpdateCustomerByIdUseCase(customerRepo: repo),
    removeCustomerByIdUseCase: RemoveCustomerByIdUseCase(customerRepo: repo),
  );
}

void main() {
  test('a save emits the updated record once', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);
    final updated = <Customer>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateCustomerById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(updated.single.id, '7');
    expect(errors, isEmpty);
    expect(vm.state.value.busy, isFalse);
    expect(repo.updatedCustomerId, '7');
  });

  test('a delete emits on its own channel, not the save one', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);
    final updated = <Customer>[];
    final removed = <Customer>[];
    vm.updated.listen(updated.add);
    vm.removed.listen(removed.add);

    await vm.removeCustomerById('9');
    await Future<void>.delayed(Duration.zero);

    expect(removed.single.id, '9');
    expect(updated, isEmpty,
        reason: 'the two outcomes cannot be mistaken for each other');
    expect(repo.removedCustomerId, '9');
  });

  test('a save then a delete deliver both, in order', () async {
    final vm = buildViewModel(FakeCustomerRepository());
    final seen = <String>[];
    vm.updated.listen((e) => seen.add('updated:${e.id}'));
    vm.removed.listen((e) => seen.add('removed:${e.id}'));

    await vm.updateCustomerById('7', buildParam());
    await vm.removeCustomerById('9');
    await Future<void>.delayed(Duration.zero);

    expect(seen, ['updated:7', 'removed:9'],
        reason: 'the old shape had one slot, so the second replaced the first');
  });

  test('a failure emits an error and no outcome', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final updated = <Customer>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateCustomerById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(updated, isEmpty);
    expect(vm.state.value.busy, isFalse);
  });

  test('a second command while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeCustomerRepository());
    final updated = <Customer>[];
    vm.updated.listen(updated.add);

    final first = vm.updateCustomerById('7', buildParam());
    await vm.updateCustomerById('7', buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(updated, hasLength(1));
  });
}
