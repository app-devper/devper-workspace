// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the submit is in flight.
///
/// The whole state used to be a sealed flow carrying the outcome, which the
/// view cleared once it had acted. The outcome closes the sheet and hands the
/// record back — nothing draws it — so it goes on the event channel.
@immutable
class ProductReturnState {
  final bool loading;

  const ProductReturnState({this.loading = false});

  ProductReturnState copyWith({bool? loading}) {
    return ProductReturnState(loading: loading ?? this.loading);
  }
}
