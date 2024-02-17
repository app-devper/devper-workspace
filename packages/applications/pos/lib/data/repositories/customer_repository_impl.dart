// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/customer_mapper.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final PosService posService;
  List<Customer> _customers = [];

  CustomerRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Customer> createCustomer(CustomerParam param) async {
    final mapper = CustomerMapper();
    final response = await posService.createCustomer(mapper.toCustomerRequest(param));
    if (response.isSuccessful) {
      return mapper.toCustomerDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final mapper = CustomerMapper();
    final response = await posService.getCustomers();
    if (response.isSuccessful) {
      final customers = mapper.toCustomersDomain(jsonDecode(response.body));
      _customers = customers;
      return customers;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    final mapper = CustomerMapper();
    final response = await posService.getCustomerById(customerId);
    if (response.isSuccessful) {
      return mapper.toCustomerDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Customer> getCustomerByCode(String customerCode) async {
    final mapper = CustomerMapper();
    final response = await posService.getCustomerByCode(customerCode);
    if (response.isSuccessful) {
      return mapper.toCustomerDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Customer> removeCustomerById(String customerId) async {
    final mapper = CustomerMapper();
    final response = await posService.removeCustomerById(customerId);
    if (response.isSuccessful) {
      return mapper.toCustomerDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) async {
    final mapper = CustomerMapper();
    final response = await posService.updateCustomerById(customerId, mapper.toCustomerRequest(param));
    if (response.isSuccessful) {
      return mapper.toCustomerDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<Customer>> getLocalCustomers() async {
    if (_customers.isEmpty) {
      return getCustomers();
    } else {
      return Future.value(_customers);
    }
  }
}
