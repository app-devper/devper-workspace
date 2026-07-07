// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductStockQuantityState {
  final bool loading;
  final String? error;
  final ProductStock? updated;

  const ProductStockQuantityState({
    this.loading = false,
    this.error,
    this.updated,
  });

  ProductStockQuantityState copyWith({
    bool? loading,
    String? error,
    ProductStock? updated,
    bool clearError = false,
    bool clearUpdated = false,
  }) {
    return ProductStockQuantityState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
    );
  }
}
