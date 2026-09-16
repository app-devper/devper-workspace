// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether a save is in flight.
///
/// It used to carry the outcome too — a sealed task holding Created or Failed,
/// with the view clearing it afterwards. Those are things the screen reacts to
/// once, not things it draws, so they go out on the view model's event channel
/// and the whole hierarchy collapses to this.
@immutable
class CustomerAddState {
  final bool saving;

  const CustomerAddState({this.saving = false});

  CustomerAddState copyWith({bool? saving}) {
    return CustomerAddState(saving: saving ?? this.saving);
  }
}
