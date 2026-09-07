// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product_history.dart';

@immutable
class ProductHistoryState {
  final List<ProductHistory> items;
  final bool loading;
  final String? error;

  const ProductHistoryState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  ProductHistoryState copyWith({
    List<ProductHistory>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ProductHistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
