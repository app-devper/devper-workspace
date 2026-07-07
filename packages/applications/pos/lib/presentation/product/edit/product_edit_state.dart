// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductEditState {
  final bool loading;
  final String? error;
  final Product? loaded;
  final List<Category> categories;
  final Product? updated;
  final Product? removed;
  final String? serialNumber;

  const ProductEditState({
    this.loading = false,
    this.error,
    this.loaded,
    this.categories = const [],
    this.updated,
    this.removed,
    this.serialNumber,
  });

  ProductEditState copyWith({
    bool? loading,
    String? error,
    Product? loaded,
    List<Category>? categories,
    Product? updated,
    Product? removed,
    String? serialNumber,
    bool clearError = false,
    bool clearLoaded = false,
    bool clearUpdated = false,
    bool clearRemoved = false,
    bool clearSerialNumber = false,
  }) {
    return ProductEditState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
      categories: categories ?? this.categories,
      updated: clearUpdated ? null : (updated ?? this.updated),
      removed: clearRemoved ? null : (removed ?? this.removed),
      serialNumber: clearSerialNumber ? null : (serialNumber ?? this.serialNumber),
    );
  }
}
