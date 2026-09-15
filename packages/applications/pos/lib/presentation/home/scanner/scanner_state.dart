// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether a lookup is in flight.
///
/// The product it found, the failures, and "ไม่พบสินค้า" all used to sit here
/// behind a sealed task. None of them is drawn — one opens the edit screen,
/// the others flash a dialog — so all three go out on the event channel.
@immutable
class ScannerState {
  final bool loading;

  const ScannerState({this.loading = false});

  ScannerState copyWith({bool? loading}) {
    return ScannerState(loading: loading ?? this.loading);
  }
}
