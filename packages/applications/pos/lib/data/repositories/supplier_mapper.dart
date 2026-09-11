// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension SupplierJson on Map<String, dynamic> {
  Supplier toSupplierDomain() {
    final json = this;

    return Supplier(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      taxId: json['taxId'],
    );
  }
}

extension SupplierListJson on List {
  List<Supplier> toSuppliersDomain() {
    final json = this;

    final lists = json
        .map((data) => (data as Map<String, dynamic>).toSupplierDomain())
        .toList();
    return lists;
  }
}

extension SupplierParamRequest on SupplierParam {
  String toSupplierRequest() {
    final param = this;

    return jsonEncode({
      'name': param.name,
      'address': param.address,
      'phone': param.phone,
      'taxId': param.taxId,
    });
  }
}
