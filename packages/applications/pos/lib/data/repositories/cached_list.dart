// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/exception.dart';

/// An in-memory list the repositories keep between reads.
///
/// Four repositories were each doing this by hand with their own policy, and
/// two of them — categories and suppliers — never told their cache that a write
/// had happened, so an edit stayed invisible until the app restarted.
///
/// A cache is a data-layer concern, so it lives here rather than behind a
/// method on a domain repository interface.
class CachedList<T> {
  List<T> _items = [];
  bool _dirty = false;
  final _changes = StreamController<void>.broadcast();

  /// Fires when what this list holds changed: a write marked it stale, or an
  /// edit was patched into it. Filling it from the server does not fire, so a
  /// screen that re-reads on a change does not loop.
  Stream<void> get changes => _changes.stream;

  /// True before the first load, and after any write that could have changed
  /// what the server would return.
  bool get needsRefresh => _dirty || _items.isEmpty;

  /// The cached items. Callers that maintain entries in place — products does,
  /// because reloading the whole catalogue after a price edit is expensive —
  /// mutate this directly.
  List<T> get items => _items;

  bool get isEmpty => _items.isEmpty;

  /// Replaces the contents with a fresh read and clears the dirty mark.
  void fill(List<T> items) {
    _items = items;
    _dirty = false;
  }

  /// Marks the cache for a refetch on the next local read. Call this from any
  /// write, including a write on another repository that changes what this one
  /// would return.
  void invalidate() {
    _dirty = true;
    _changes.add(null);
  }

  /// Says an edit was patched into [items] in place.
  void touch() => _changes.add(null);

  /// Runs [write] and marks the list stale unless the server refused it.
  ///
  /// pos-api applies a Stock ledger write in one transaction, so a 4xx means
  /// nothing moved. A 5xx, a timeout or a dropped connection proves nothing
  /// either way, and a needless refetch is cheaper than serving what the
  /// server no longer holds.
  Future<R> staleAfter<R>(Future<R> Function() write) async {
    try {
      final result = await write();
      invalidate();
      return result;
    } catch (e) {
      if (!_refused(e)) invalidate();
      rethrow;
    }
  }

  static bool _refused(Object e) => switch (e) {
        ValidationException() ||
        ConflictException() ||
        NotFoundException() ||
        ForbiddenException() ||
        AuthException() =>
          true,
        UnknownHttpException(:final statusCode) => statusCode < 500,
        _ => false,
      };
}
