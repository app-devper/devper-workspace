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
  Future<Customer> createCustomer(CustomerParam param) => throw UnimplementedError();

  @override
  Future<List<Customer>> getCustomers() => throw UnimplementedError();

  @override
  Future<Customer> getCustomerByCode(String customerCode) => throw UnimplementedError();

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) => throw UnimplementedError();

  @override
  Future<Customer> removeCustomerById(String customerId) => throw UnimplementedError();
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

void main() {
  group('CustomersViewModel', () {
    test('getCustomers populates items from the local cache', () async {
      final vm = CustomersViewModel(
        customerRepo: FakeCustomerRepository(customers: [buildCustomer('1')]),
      );

      await vm.getCustomers();

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items, hasLength(1));
      expect(vm.state.value.error, isNull);
    });

    test('getCustomers maps a typed exception to state.error', () async {
      final vm = CustomersViewModel(
        customerRepo: FakeCustomerRepository(throws: const NetworkException(message: 'offline')),
      );

      await vm.getCustomers();

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.items, isEmpty);
    });
  });

  group('CustomerViewModel', () {
    test('getCustomerById sets the loaded customer once', () async {
      final vm = CustomerViewModel(
        customerRepo: FakeCustomerRepository(byId: buildCustomer('7')),
      );

      await vm.getCustomerById('7');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.loaded?.id, '7');

      vm.consumeLoaded();

      expect(vm.state.value.loaded, isNull);
    });

    test('getCustomerById maps a typed exception to state.error', () async {
      final vm = CustomerViewModel(
        customerRepo: FakeCustomerRepository(throws: const NotFoundException(message: 'missing')),
      );

      await vm.getCustomerById('x');

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.loaded, isNull);
    });
  });
}
