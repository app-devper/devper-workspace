import 'package:flutter/foundation.dart';
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductSearchState {
  final List<ProductUnitItem> items;
  final bool loading;
  final String? error;

  const ProductSearchState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  ProductSearchState copyWith({
    List<ProductUnitItem>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ProductSearchState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
