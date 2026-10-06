import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
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
  Future<Customer> getCustomerById(String customerId) =>
      throw UnimplementedError();

  @override
  Future<Customer> getCustomerByCode(String customerCode) =>
      throw UnimplementedError();

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) =>
      throw UnimplementedError();

  @override
  Future<Customer> removeCustomerById(String customerId) =>
      throw UnimplementedError();
}

CustomerParam buildParam() {
  return CustomerParam(
      name: 'สมชาย',
      address: '',
      phone: '0812345678',
      email: '',
      customerType: 'GENERAL');
}

CustomerAddViewModel buildViewModel(CustomerRepository repo) {
  return CustomerAddViewModel(
    customerRepo: repo,
  );
}

void main() {
  test('initial state is not saving', () {
    final vm = buildViewModel(FakeCustomerRepository());

    expect(vm.state.value.saving, isFalse);
  });

  test('a successful save emits the customer once', () async {
    final repo = FakeCustomerRepository();
    final vm = buildViewModel(repo);
    final created = <Customer>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createCustomer(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(created.single.name, isNotEmpty);
    expect(errors, isEmpty);
    expect(repo.createdParam, isNotNull);
  });

  test('a failure emits on the error channel and nothing on created', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final created = <Customer>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createCustomer(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(errors, hasLength(1));
    expect(created, isEmpty);
  });

  test('an outcome is delivered once, with nothing to clear', () async {
    final vm = buildViewModel(FakeCustomerRepository());
    final created = <Customer>[];
    vm.created.listen(created.add);

    await vm.createCustomer(buildParam());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1),
        reason: 'the old shape needed consumeCreated to stop it repeating');
  });

  test('a second save while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeCustomerRepository());
    final created = <Customer>[];
    vm.created.listen(created.add);

    final first = vm.createCustomer(buildParam());
    await vm.createCustomer(buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1));
  });
}
