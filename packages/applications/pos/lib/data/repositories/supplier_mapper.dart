// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

class SupplierMapper {
  const SupplierMapper();

  List<Supplier> toSuppliersDomain(List json) {
    final lists = json.map((data) => toSupplierDomain(data)).toList();
    return lists;
  }

  Supplier toSupplierDomain(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      taxId: json['taxId'],
    );
  }

  String toSupplierRequest(SupplierParam param) {
    return jsonEncode({
      'name': param.name,
      'address': param.address,
      'phone': param.phone,
      'taxId': param.taxId,
    });
  }
}
