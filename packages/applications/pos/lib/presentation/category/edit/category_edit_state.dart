// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

/// What this screen renders: whether a command is in flight.
///
/// Saving and deleting used to be separate states in a sealed type that also
/// carried the outcome, and the view cleared the outcome once it had acted.
/// The outcomes are events now, and one flag is enough here — the screen runs
/// one command at a time, and starting a delete mid-save was never wanted.
@immutable
class CategoryEditState {
  final bool busy;

  const CategoryEditState({this.busy = false});

  bool get loading => busy;

  CategoryEditState copyWith({bool? busy}) {
    return CategoryEditState(busy: busy ?? this.busy);
  }
}
