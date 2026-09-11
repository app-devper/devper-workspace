// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';

class CategoryMapper {
  const CategoryMapper();

  List<Category> toCategoriesDomain(List json) {
    final lists = json.map((data) => toCategoryDomain(data)).toList();
    return lists;
  }

  Category toCategoryDomain(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      description: json['description'],
      isDefault: json['default'],
      requireCustomerOrder: json['requireCustomerOrder'] ?? false,
    );
  }

  String toCategoryRequest(CategoryParam param) {
    return jsonEncode({
      'name': param.name,
      'value': param.value,
      'description': param.description,
      'requireCustomerOrder': param.requireCustomerOrder,
    });
  }
}
