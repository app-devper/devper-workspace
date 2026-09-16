// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and these only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// Note the casts at the call sites. jsonOrThrow returns dynamic, and an
/// extension method cannot be reached through a dynamic receiver — it compiles
/// and then throws NoSuchMethodError at runtime. Casting first is what keeps
/// that mistake a compile error.
extension CategoryJson on Map<String, dynamic> {
  Category toCategoryDomain() {
    return Category(
      id: this['id'],
      name: this['name'],
      value: this['value'],
      description: this['description'],
      isDefault: this['default'],
      requireCustomerOrder: this['requireCustomerOrder'] ?? false,
    );
  }
}

extension CategoryListJson on List {
  List<Category> toCategoriesDomain() {
    return map((data) => (data as Map<String, dynamic>).toCategoryDomain())
        .toList();
  }
}

extension CategoryRequest on CategoryParam {
  String toCategoryRequest() {
    return jsonEncode({
      'name': name,
      'value': value,
      'description': description,
      'requireCustomerOrder': requireCustomerOrder,
    });
  }
}
