// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';

abstract class CustomerRepository {
  Future<Customer> createCustomer(CustomerParam param);

  Future<List<Customer>> getCustomers();

  Future<List<Customer>> getLocalCustomers();

  Future<Customer> getCustomerById(String customerId);

  Future<Customer> getCustomerByCode(String customerCode);

  Future<Customer> updateCustomerById(String customerId, CustomerParam param);

  Future<Customer> removeCustomerById(String customerId);
}
