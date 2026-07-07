// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductUnitState {
  final bool loading;
  final String? error;
  final List<ProductUnit> items;
  final ProductUnit? completed;

  const ProductUnitState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.completed,
  });

  ProductUnitState copyWith({
    bool? loading,
    String? error,
    List<ProductUnit>? items,
    ProductUnit? completed,
    bool clearError = false,
    bool clearCompleted = false,
  }) {
    return ProductUnitState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      completed: clearCompleted ? null : (completed ?? this.completed),
    );
  }
}
