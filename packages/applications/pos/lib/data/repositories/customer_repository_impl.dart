// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/customer_mapper.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final PosService posService;
  final _customers = CachedList<Customer>();

  CustomerRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Customer> createCustomer(CustomerParam param) async {
    final response = await posService.createCustomer(param.toCustomerRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toCustomerDomain();
    _customers.invalidate();
    return result;
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final response = await posService.getCustomers();
    final customers = (jsonOrThrow(response) as List).toCustomersDomain();
    _customers.fill(customers);
    return customers;
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    final cached = _customers.needsRefresh
        ? null
        : _customers.items
            .where((element) => element.id == customerId)
            .firstOrNull;
    if (cached != null) {
      return cached;
    }
    final response = await posService.getCustomerById(customerId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toCustomerDomain();
  }

  @override
  Future<Customer> getCustomerByCode(String customerCode) async {
    final response = await posService.getCustomerByCode(customerCode);
    return (jsonOrThrow(response) as Map<String, dynamic>).toCustomerDomain();
  }

  @override
  Future<Customer> removeCustomerById(String customerId) async {
    final response = await posService.removeCustomerById(customerId);
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toCustomerDomain();
    _customers.invalidate();
    return result;
  }

  @override
  Future<Customer> updateCustomerById(
      String customerId, CustomerParam param) async {
    final response = await posService.updateCustomerById(
        customerId, param.toCustomerRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toCustomerDomain();
    _customers.invalidate();
    return result;
  }

  @override
  Future<List<Customer>> getLocalCustomers() async {
    if (_customers.needsRefresh) {
      return getCustomers();
    }
    return Future.value(_customers.items);
  }
}
