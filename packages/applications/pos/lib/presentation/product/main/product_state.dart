// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';

@immutable
class ProductState {
  final bool loading;
  final String? error;
  final Product? loaded;
  final CSVImportResult? importResult;

  const ProductState({
    this.loading = false,
    this.error,
    this.loaded,
    this.importResult,
  });

  ProductState copyWith({
    bool? loading,
    String? error,
    Product? loaded,
    CSVImportResult? importResult,
    bool clearError = false,
    bool clearLoaded = false,
    bool clearImportResult = false,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
      importResult: clearImportResult ? null : (importResult ?? this.importResult),
    );
  }
}
