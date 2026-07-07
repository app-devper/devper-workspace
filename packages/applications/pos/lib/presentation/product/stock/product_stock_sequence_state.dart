// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ProductStockSequenceState {
  final bool loading;
  final String? error;
  final List<ProductStock>? updated;

  const ProductStockSequenceState({
    this.loading = false,
    this.error,
    this.updated,
  });

  ProductStockSequenceState copyWith({
    bool? loading,
    String? error,
    List<ProductStock>? updated,
    bool clearError = false,
    bool clearUpdated = false,
  }) {
    return ProductStockSequenceState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
    );
  }
}
