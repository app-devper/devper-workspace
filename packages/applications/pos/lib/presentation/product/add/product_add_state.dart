// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductAddState {
  final bool saving;
  final String? error;
  final List<Category> categories;
  final Product? created;
  final String? serialNumber;

  const ProductAddState({
    this.saving = false,
    this.error,
    this.categories = const [],
    this.created,
    this.serialNumber,
  });

  ProductAddState copyWith({
    bool? saving,
    String? error,
    List<Category>? categories,
    Product? created,
    String? serialNumber,
    bool clearError = false,
    bool clearCreated = false,
    bool clearSerialNumber = false,
  }) {
    return ProductAddState(
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      categories: categories ?? this.categories,
      created: clearCreated ? null : (created ?? this.created),
      serialNumber: clearSerialNumber ? null : (serialNumber ?? this.serialNumber),
    );
  }
}
