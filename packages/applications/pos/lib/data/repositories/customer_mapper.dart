// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension CustomerJson on Map<String, dynamic> {
  Customer toCustomerDomain() {
    final json = this;

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
}

extension CustomerListJson on List {
  List<Customer> toCustomersDomain() {
    final json = this;

    final lists = json
        .map((data) => (data as Map<String, dynamic>).toCustomerDomain())
        .toList();
    return lists;
  }
}

extension CustomerParamRequest on CustomerParam {
  String toCustomerRequest() {
    final param = this;

    return jsonEncode({
      'name': param.name,
      'address': param.address,
      'phone': param.phone,
      'email': param.email,
      'customerType': param.customerType,
    });
  }
}
