// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the save is in flight.
///
/// The lot to fill the form with and the saved result used to sit here behind
/// a sealed task the view cleared. Both are handed over once — one fills the
/// fields, the other flashes a confirmation — so both go on the event channel.
@immutable
class ProductLotEditState {
  final bool loading;

  const ProductLotEditState({this.loading = false});

  ProductLotEditState copyWith({bool? loading}) {
    return ProductLotEditState(loading: loading ?? this.loading);
  }
}
