// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether a command is in flight.
///
/// The product it opened, the CSV tally, the failures and "Product not found"
/// all used to sit here behind a sealed task the view cleared. None of them is
/// drawn — one swaps the panel, the rest flash a snackbar — so all four go out
/// on the view model's event channel.
@immutable
class ProductState {
  final bool loading;

  const ProductState({this.loading = false});

  ProductState copyWith({bool? loading}) {
    return ProductState(loading: loading ?? this.loading);
  }
}
