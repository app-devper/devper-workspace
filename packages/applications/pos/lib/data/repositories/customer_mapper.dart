// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';

class CustomerMapper {
  List<Customer> toCustomersDomain(List json) {
    final lists = json.map((data) => toCustomerDomain(data)).toList();
    return lists;
  }

  Customer toCustomerDomain(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
      type: json['customerType'] ?? 'General',
    );
  }

  String toCustomerRequest(CustomerParam param) {
    return jsonEncode({
      'name': param.name,
      'address': param.address,
      'phone': param.phone,
      'email': param.email,
      'customerType': param.customerType,
    });
  }
}
