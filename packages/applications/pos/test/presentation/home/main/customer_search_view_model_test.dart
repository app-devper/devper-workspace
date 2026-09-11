import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/presentation/home/main/customer_search_view_model.dart';

class FakeCustomerRepository implements CustomerRepository {
  final List<Customer> customers;
  final Object? throws;

  FakeCustomerRepository({this.customers = const [], this.throws});

  @override
  Future<List<Customer>> getLocalCustomers() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return customers;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Customer buildCustomer(String id, String name, String phone) {
  return Customer(
    id: id,
    code: 'C$id',
    name: name,
    address: '',
    phone: phone,
    email: '',
    status: 'ACTIVE',
    type: '',
  );
}

CustomerSearchViewModel buildViewModel(CustomerRepository repo) {
  return CustomerSearchViewModel(
    getLocalCustomersUseCase: GetLocalCustomersUseCase(customerRepo: repo),
  );
}

final _cached = [
  buildCustomer('1', 'สมชาย ใจดี', '0812345678'),
  buildCustomer('2', 'Somsri Wong', '0898888888'),
  buildCustomer('3', 'สมหญิง รักดี', '0812340000'),
];

void main() {
  test('the cache populates the list', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));

    await vm.getCacheCustomers();

    expect(vm.items.value, hasLength(3));
  });

  test('a failed cache read leaves the list untouched', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
          throws: const NetworkException(message: 'offline')),
    );

    await vm.getCacheCustomers();

    // The view model swallows this deliberately — the search box stays usable
    // and simply has nothing to offer.
    expect(vm.items.value, isNull);
  });

  test('an empty term restores the whole list', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));
    await vm.getCacheCustomers();

    vm.searchCustomer('สม');
    expect(vm.items.value, hasLength(2));

    vm.searchCustomer('');

    expect(vm.items.value, hasLength(3));
  });

  test('name matching ignores case', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));
    await vm.getCacheCustomers();

    vm.searchCustomer('somsri');

    expect(vm.items.value?.single.name, 'Somsri Wong');
  });

  test('a phone prefix matches several customers', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));
    await vm.getCacheCustomers();

    vm.searchCustomer('08123');

    expect(vm.items.value?.map((e) => e.id), ['1', '3']);
  });

  test('phone matching is not case-folded into the name match', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));
    await vm.getCacheCustomers();

    vm.searchCustomer('0898888888');

    expect(vm.items.value?.single.id, '2');
  });

  test('no match yields an empty list, not the full one', () async {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));
    await vm.getCacheCustomers();

    vm.searchCustomer('ไม่มีใครชื่อนี้');

    expect(vm.items.value, isEmpty);
  });

  test('searching before the cache loads does not throw', () {
    final vm = buildViewModel(FakeCustomerRepository(customers: _cached));

    vm.searchCustomer('สม');

    expect(vm.items.value, isEmpty);
  });
}
