// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether a save is in flight.
///
/// It used to carry the outcome too — a sealed task holding Created or Failed,
/// with the view clearing it afterwards. Those are things the screen reacts to
/// once, not things it draws, so they go out on the view model's event channel
/// and the whole hierarchy collapses to this.
@immutable
class SupplierAddState {
  final bool saving;

  const SupplierAddState({this.saving = false});

  SupplierAddState copyWith({bool? saving}) {
    return SupplierAddState(saving: saving ?? this.saving);
  }
}
