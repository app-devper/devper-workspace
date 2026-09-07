// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product_return/product_return.dart';

@immutable
class ProductReturnState {
  final bool loading;
  final String? error;
  final ProductReturn? created;

  const ProductReturnState({
    this.loading = false,
    this.error,
    this.created,
  });

  ProductReturnState copyWith({
    bool? loading,
    String? error,
    ProductReturn? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return ProductReturnState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
