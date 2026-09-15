// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the lookup is in flight.
///
/// The customer it found used to sit here behind a sealed task the view
/// cleared. It is handed to the page once to build the info panel, so it goes
/// out on the event channel instead.
@immutable
class CustomerState {
  final bool loading;

  const CustomerState({this.loading = false});

  CustomerState copyWith({bool? loading}) {
    return CustomerState(loading: loading ?? this.loading);
  }
}
