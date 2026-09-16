// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether a command is in flight.
///
/// Saving and deleting used to be separate states in a sealed type that also
/// carried the outcome, and the view cleared the outcome once it had acted.
/// The outcomes are events now, and one flag is enough here — the screen runs
/// one command at a time, and starting a delete mid-save was never wanted.
@immutable
class SupplierEditState {
  final bool busy;

  const SupplierEditState({this.busy = false});

  bool get loading => busy;

  SupplierEditState copyWith({bool? busy}) {
    return SupplierEditState(busy: busy ?? this.busy);
  }
}
