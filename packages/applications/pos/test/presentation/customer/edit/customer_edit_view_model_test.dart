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
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) async {
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
  Future<Customer> createCustomer(CustomerParam param) => throw UnimplementedError();

  @override
  Future<List<Customer>> getCustomers() => throw UnimplementedError();

  @override
  Future<List<Customer>> getLocalCustomers() => throw UnimplementedError();

  @override
  Future<Customer> getCustomerById(String customerId) => throw UnimplementedError();

  @override
  Future<Customer> getCustomerByCode(String customerCode) => throw UnimplementedError();
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
  return CustomerParam(name: 'สมหญิง', address: '', phone: '', email: '', customerType: 'GENERAL');
}

CustomerEditViewModel buildViewModel(CustomerRepository repo) {
  return CustomerEditViewModel(
    updateCustomerByIdUseCase: UpdateCustomerByIdUseCase(customerRepo: repo),
    removeCustomerByIdUseCase: RemoveCustomerByIdUseCase(customerRepo: repo),
  );
}

void main() {
  test('updateCustomerById sets updated on success', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);

    await vm.updateCustomerById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated?.id, '7');
    expect(repo.updatedCustomerId, '7');
    expect(vm.state.value.error, isNull);
  });

  test('updateCustomerById maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateCustomerById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('removeCustomerById sets removed on success', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);

    await vm.removeCustomerById('9');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.removed?.id, '9');
    expect(repo.removedCustomerId, '9');
  });

  test('consumeUpdated clears the updated result', () async {
    final vm = buildViewModel(FakeCustomerRepository());

    await vm.updateCustomerById('7', buildParam());
    expect(vm.state.value.updated, isNotNull);

    vm.consumeUpdated();

    expect(vm.state.value.updated, isNull);
  });

  test('consumeRemoved clears the removed result', () async {
    final vm = buildViewModel(FakeCustomerRepository());

    await vm.removeCustomerById('9');
    expect(vm.state.value.removed, isNotNull);

    vm.consumeRemoved();

    expect(vm.state.value.removed, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.updateCustomerById('7', buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
