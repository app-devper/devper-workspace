// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';

@immutable
class ProductLotEditState {
  final bool loading;
  final String? error;
  final ProductLot? loaded;
  final ProductLot? updated;

  const ProductLotEditState({
    this.loading = false,
    this.error,
    this.loaded,
    this.updated,
  });

  ProductLotEditState copyWith({
    bool? loading,
    String? error,
    ProductLot? loaded,
    ProductLot? updated,
    bool clearError = false,
    bool clearLoaded = false,
    bool clearUpdated = false,
  }) {
    return ProductLotEditState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
      updated: clearUpdated ? null : (updated ?? this.updated),
    );
  }
}
