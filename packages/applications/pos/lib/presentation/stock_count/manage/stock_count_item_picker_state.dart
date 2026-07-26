// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class StockCountItemPickerState {
  final List<ProductUnitItem> products;
  final bool loading;
  final ProductUnitItem? selectedProduct;
  final String? error;

  const StockCountItemPickerState({
    this.products = const [],
    this.loading = false,
    this.selectedProduct,
    this.error,
  });

  StockCountItemPickerState copyWith({
    List<ProductUnitItem>? products,
    bool? loading,
    ProductUnitItem? selectedProduct,
    bool clearSelectedProduct = false,
    String? error,
    bool clearError = false,
  }) {
    return StockCountItemPickerState(
      products: products ?? this.products,
      loading: loading ?? this.loading,
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
