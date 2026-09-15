// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the submit is in flight.
///
/// The whole state used to be a sealed flow carrying the outcome, which the
/// view cleared once it had acted. The outcome closes the sheet and hands the
/// record back — nothing draws it — so it goes on the event channel.
@immutable
class StockAdjustmentState {
  final bool loading;

  const StockAdjustmentState({this.loading = false});

  StockAdjustmentState copyWith({bool? loading}) {
    return StockAdjustmentState(loading: loading ?? this.loading);
  }
}
