import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/customer/main/customers_view_model.dart';

class FakeCustomerRepository implements CustomerRepository {
  final List<Customer> customers;
  final Customer? byId;
  final Object? throws;

  FakeCustomerRepository({this.customers = const [], this.byId, this.throws});

  @override
  Future<List<Customer>> getLocalCustomers() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return customers;
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return byId ?? customers.first;
  }

  @override
  Future<Customer> createCustomer(CustomerParam param) =>
      throw UnimplementedError();

  @override
  Future<List<Customer>> getCustomers() => throw UnimplementedError();

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

CustomersViewModel buildCustomersViewModel(CustomerRepository repo) {
  return CustomersViewModel(
    customerRepo: repo,
  );
}

CustomerViewModel buildCustomerViewModel(CustomerRepository repo) {
  return CustomerViewModel(
    customerRepo: repo,
  );
}

void main() {
  group('CustomersViewModel', () {
    test('getCustomers populates items from the local cache', () async {
      final vm = buildCustomersViewModel(
          FakeCustomerRepository(customers: [buildCustomer('1')]));

      await vm.getCustomers();

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items, hasLength(1));
    });

    test('getCustomers maps a typed exception to state.error', () async {
      final vm = buildCustomersViewModel(
        FakeCustomerRepository(
            throws: const NetworkException(message: 'offline')),
      );

      await vm.getCustomers();

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.items, isEmpty);
    });
  });

  group('CustomerViewModel', () {
    test('a lookup emits the customer once', () async {
      final vm = buildCustomerViewModel(
          FakeCustomerRepository(byId: buildCustomer('7')));
      final loaded = <Customer>[];
      vm.loaded.listen(loaded.add);

      await vm.getCustomerById('7');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.loading, isFalse);
      expect(loaded.single.id, '7');
    });

    test('a failed lookup reaches the screen instead of going nowhere',
        () async {
      // The page only listened for the result, so a failure left the panel
      // unchanged and told the user nothing.
      final vm = buildCustomerViewModel(
        FakeCustomerRepository(
            throws: const NotFoundException(message: 'missing')),
      );
      final loaded = <Customer>[];
      final errors = <String>[];
      vm.loaded.listen(loaded.add);
      vm.errors.listen(errors.add);

      await vm.getCustomerById('x');
      await Future<void>.delayed(Duration.zero);

      expect(errors, hasLength(1));
      expect(loaded, isEmpty);
    });
  });
}
