// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/error_mapper.dart';
import 'package:common/core/network/exception.dart';

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
    final mapper = CustomerMapper();
    final response = await posService.createCustomer(mapper.toCustomerRequest(param));
    if (response.isSuccessful) {
      final result = mapper.toCustomerDomain(jsonDecode(response.body));
      _customers.invalidate();
      return result;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final mapper = CustomerMapper();
    final response = await posService.getCustomers();
    if (response.isSuccessful) {
      final customers = mapper.toCustomersDomain(jsonDecode(response.body));
      _customers.fill(customers);
      return customers;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    final mapper = CustomerMapper();
    final cached = _customers.needsRefresh
        ? null
        : _customers.items
            .where((element) => element.id == customerId)
            .firstOrNull;
    if (cached != null) {
      return cached;
    }
    final response = await posService.getCustomerById(customerId);
    return mapper.toCustomerDomain(jsonOrThrow(response));
  }

  @override
  Future<Customer> getCustomerByCode(String customerCode) async {
    final mapper = CustomerMapper();
    final response = await posService.getCustomerByCode(customerCode);
    return mapper.toCustomerDomain(jsonOrThrow(response));
  }

  @override
  Future<Customer> removeCustomerById(String customerId) async {
    final mapper = CustomerMapper();
    final response = await posService.removeCustomerById(customerId);
    if (response.isSuccessful) {
      final result = mapper.toCustomerDomain(jsonDecode(response.body));
      _customers.invalidate();
      return result;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) async {
    final mapper = CustomerMapper();
    final response = await posService.updateCustomerById(customerId, mapper.toCustomerRequest(param));
    if (response.isSuccessful) {
      final result = mapper.toCustomerDomain(jsonDecode(response.body));
      _customers.invalidate();
      return result;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<List<Customer>> getLocalCustomers() async {
    if (_customers.needsRefresh) {
      return getCustomers();
    }
    return Future.value(_customers.items);
  }
}
