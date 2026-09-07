// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductPriceState {
  final bool loading;
  final String? error;
  final List<ProductPrice> items;
  final ProductPrice? completed;

  const ProductPriceState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.completed,
  });

  ProductPriceState copyWith({
    bool? loading,
    String? error,
    List<ProductPrice>? items,
    ProductPrice? completed,
    bool clearError = false,
    bool clearCompleted = false,
  }) {
    return ProductPriceState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      completed: clearCompleted ? null : (completed ?? this.completed),
    );
  }
}
