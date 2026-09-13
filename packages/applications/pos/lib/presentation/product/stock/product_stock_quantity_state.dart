// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the command is in flight.
///
/// The outcome used to live here too, behind a sealed task the view cleared
/// once it had acted on it. It is not drawn — it closes the screen and hands
/// the result back — so it goes out on the view model's event channel.
@immutable
class ProductStockQuantityState {
  final bool loading;

  const ProductStockQuantityState({
    this.loading = false,
  });

  ProductStockQuantityState copyWith({
    bool? loading,
  }) {
    return ProductStockQuantityState(
      loading: loading ?? this.loading,
    );
  }
}
