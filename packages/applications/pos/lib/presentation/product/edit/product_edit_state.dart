// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders while a command runs.
///
/// It used to hold four command results and an error, each cleared by a
/// `consume*()` the page had to remember to call, plus a list of categories
/// nothing ever read — the picker is built from the [ItemType] constants in
/// `categoryTypes`, not from state. All five are gone; the form is seeded from
/// the document when it arrives on the channel and edits itself after that.
@immutable
class ProductEditState {
  final bool loading;

  const ProductEditState({this.loading = false});

  ProductEditState copyWith({bool? loading}) {
    return ProductEditState(loading: loading ?? this.loading);
  }
}
