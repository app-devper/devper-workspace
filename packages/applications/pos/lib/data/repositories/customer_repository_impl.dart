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
  static const _mapper = CustomerMapper();

  final PosService posService;
  final _customers = CachedList<Customer>();

  CustomerRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Customer> createCustomer(CustomerParam param) async {
    final response = await posService.createCustomer(_mapper.toCustomerRequest(param));
    final result = _mapper.toCustomerDomain(jsonOrThrow(response));
    _customers.invalidate();
    return result;
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final response = await posService.getCustomers();
    final customers = _mapper.toCustomersDomain(jsonOrThrow(response));
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
    return _mapper.toCustomerDomain(jsonOrThrow(response));
  }

  @override
  Future<Customer> getCustomerByCode(String customerCode) async {
    final response = await posService.getCustomerByCode(customerCode);
    return _mapper.toCustomerDomain(jsonOrThrow(response));
  }

  @override
  Future<Customer> removeCustomerById(String customerId) async {
    final response = await posService.removeCustomerById(customerId);
    final result = _mapper.toCustomerDomain(jsonOrThrow(response));
    _customers.invalidate();
    return result;
  }

  @override
  Future<Customer> updateCustomerById(String customerId, CustomerParam param) async {
    final response = await posService.updateCustomerById(customerId, _mapper.toCustomerRequest(param));
    final result = _mapper.toCustomerDomain(jsonOrThrow(response));
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
