import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/presentation/home/main/customer_search_view_model.dart';

class FakeCustomerRepository implements CustomerRepository {
  final List<Customer> customers;
  final Object? error;

  FakeCustomerRepository({this.customers = const [], this.error});

  @override
  Future<List<Customer>> getLocalCustomers() async {
    if (error != null) throw error!;
    return customers;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Customer buildCustomer(String id, String name, String phone) {
  return Customer(
    id: id,
    code: 'C-$id',
    name: name,
    address: '',
    phone: phone,
    email: '',
    status: 'Active',
    type: 'General',
  );
}

CustomerSearchViewModel buildViewModel(CustomerRepository repository) {
  return CustomerSearchViewModel(
    getLocalCustomersUseCase: GetLocalCustomersUseCase(
      customerRepo: repository,
    ),
  );
}

void main() {
  test('getCacheCustomers loads customers', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
        customers: [buildCustomer('1', 'สมชาย', '0811111111')],
      ),
    );

    await vm.getCacheCustomers();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items.single.id, '1');
    expect(vm.state.value.error, isNull);
  });

  test('searchCustomer filters by phone', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
        customers: [
          buildCustomer('1', 'สมชาย', '0811111111'),
          buildCustomer('2', 'สมหญิง', '0822222222'),
        ],
      ),
    );

    await vm.getCacheCustomers();
    vm.searchCustomer('082');

    expect(vm.state.value.items.map((item) => item.id), ['2']);
  });

  test('getCacheCustomers maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCustomerRepository(
        error: const NetworkException(message: 'offline'),
      ),
    );

    await vm.getCacheCustomers();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNotNull);
  });
}
