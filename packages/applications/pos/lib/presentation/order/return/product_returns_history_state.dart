// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product_return/product_return.dart';

@immutable
class ProductReturnsHistoryState {
  final List<ProductReturn> items;
  final bool loading;
  final String? error;

  const ProductReturnsHistoryState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  ProductReturnsHistoryState copyWith({
    List<ProductReturn>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ProductReturnsHistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
