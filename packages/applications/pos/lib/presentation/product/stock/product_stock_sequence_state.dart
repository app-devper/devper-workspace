// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the command is in flight.
///
/// The outcome used to live here too, behind a sealed task the view cleared
/// once it had acted on it. It is not drawn — it closes the screen and hands
/// the result back — so it goes out on the view model's event channel.
@immutable
class ProductStockSequenceState {
  final bool loading;

  const ProductStockSequenceState({
    this.loading = false,
  });

  ProductStockSequenceState copyWith({
    bool? loading,
  }) {
    return ProductStockSequenceState(
      loading: loading ?? this.loading,
    );
  }
}
