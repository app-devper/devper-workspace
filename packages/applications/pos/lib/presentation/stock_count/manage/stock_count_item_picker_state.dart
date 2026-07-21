// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class StockCountItemPickerState {
  final List<ProductUnitItem> products;
  final bool loading;
  final ProductUnitItem? selectedProduct;

  const StockCountItemPickerState({
    this.products = const [],
    this.loading = false,
    this.selectedProduct,
  });

  StockCountItemPickerState copyWith({
    List<ProductUnitItem>? products,
    bool? loading,
    ProductUnitItem? selectedProduct,
    bool clearSelectedProduct = false,
  }) {
    return StockCountItemPickerState(
      products: products ?? this.products,
      loading: loading ?? this.loading,
      selectedProduct: clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
    );
  }
}
