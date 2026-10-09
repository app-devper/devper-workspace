// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

/// Whether a catalogue edit is on its way to the server.
@immutable
class CatalogueEditState {
  final bool loading;

  const CatalogueEditState({this.loading = false});
}

/// One edit to the catalogue from a dialog: a Unit, a Price, a Stock, its
/// quantity or selling order, or an Adjustment. The dialogs did this through
/// six near-identical view models; two of them let a second tap send the
/// edit again.
///
/// [run] sends one edit at a time and ignores another while it is on its
/// way. Its result is delivered once on [completed], a failure once on
/// [errors]; the dialog closes or explains, and nothing else is drawn.
class CatalogueEdit<T> {
  final _state = ValueNotifier<CatalogueEditState>(const CatalogueEditState());
  final _completed = OneShot<T>();
  final _errors = OneShot<String>();

  ValueListenable<CatalogueEditState> get state => _state;

  Stream<T> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> run(Future<T> Function() edit) async {
    if (_state.value.loading) return;
    _state.value = const CatalogueEditState(loading: true);
    try {
      _completed.emit(await edit());
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = const CatalogueEditState();
    }
  }

  void dispose() {
    _state.dispose();
    _completed.dispose();
    _errors.dispose();
  }
}
