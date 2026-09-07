// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductsState {
  final List<Product> items;
  final bool loading;
  final String? error;

  const ProductsState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  ProductsState copyWith({
    List<Product>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ProductsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
