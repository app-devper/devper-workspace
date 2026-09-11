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
  void invalidate() => _dirty = true;
}
