// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

@immutable
class ScannerState {
  final bool loading;
  final String? error;
  final Product? loaded;

  const ScannerState({
    this.loading = false,
    this.error,
    this.loaded,
  });

  ScannerState copyWith({
    bool? loading,
    String? error,
    Product? loaded,
    bool clearError = false,
    bool clearLoaded = false,
  }) {
    return ScannerState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
    );
  }
}
