// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductStockState {
  final bool loading;
  final String? error;
  final List<ProductStock> items;
  final ProductStock? completed;

  const ProductStockState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.completed,
  });

  ProductStockState copyWith({
    bool? loading,
    String? error,
    List<ProductStock>? items,
    ProductStock? completed,
    bool clearError = false,
    bool clearCompleted = false,
  }) {
    return ProductStockState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      completed: clearCompleted ? null : (completed ?? this.completed),
    );
  }
}
