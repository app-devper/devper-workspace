import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/usecase/customer/create_customer_use_case.dart';
import 'package:pos/presentation/customer/add/customer_add_view_model.dart';

class FakeCustomerRepository implements CustomerRepository {
  final Object? throws;
  CustomerParam? createdParam;

  FakeCustomerRepository({this.throws});

  @override
  Future<Customer> createCustomer(CustomerParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    createdParam = param;
    return Customer(
      id: '1',
      code: 'C001',
      name: param.name,
      address: param.address,
      phone: param.phone,
      email: param.email,
      status: 'ACTIVE',
      type: param.customerType,
    );
  }

  @override
  Future<List<Customer>> getCustomers() => throw UnimplementedError();

  @override
  Future<List<Customer>> getLocalCustomers() => throw UnimplementedError();

  @override
  Future<Customer> getCustomerById(String customerId) => throw UnimplementedError();

  @override
  Future<Customer> getCustomerByCode(String customerCode) => throw UnimplementedError();

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) => throw UnimplementedError();

  @override
  Future<Customer> removeCustomerById(String customerId) => throw UnimplementedError();
}

CustomerParam buildParam() {
  return CustomerParam(name: 'สมชาย', address: '', phone: '0812345678', email: '', customerType: 'GENERAL');
}

CustomerAddViewModel buildViewModel(CustomerRepository repo) {
  return CustomerAddViewModel(
    createCustomerUseCase: CreateCustomerUseCase(customerRepo: repo),
  );
}

void main() {
  test('initial state is not saving with no result', () {
    final vm = buildViewModel(FakeCustomerRepository());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNull);
  });

  test('createCustomer sets created on success', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);

    await vm.createCustomer(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created?.name, 'สมชาย');
    expect(repo.createdParam?.phone, '0812345678');
    expect(vm.state.value.error, isNull);
  });

  test('createCustomer maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createCustomer(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('consumeCreated clears the created result', () async {
    final vm = buildViewModel(FakeCustomerRepository());

    await vm.createCustomer(buildParam());
    expect(vm.state.value.created, isNotNull);

    vm.consumeCreated();

    expect(vm.state.value.created, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createCustomer(buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
