import 'dart:async';

/// A channel for the things that happen once.
///
/// The view models here keep one immutable state object, which is right for
/// what a screen renders — a list, a loading flag, whether the user is an
/// admin. It is wrong for what a screen *reacts* to: an error to show, a saved
/// record to pop with, a signal to reload. Those were being parked in the same
/// state and cleared afterwards by a `consume*()` call the view had to
/// remember to make. Forget one and it fires again on the next notification;
/// every "stale result" bug in this app came from that.
///
/// An event put in here is delivered once and gone. There is nothing to clear,
/// so there is nothing to forget.
///
/// ```dart
/// // view model
/// final _events = OneShot<ProductEvent>();
/// Stream<ProductEvent> get events => _events.stream;
/// _events.emit(const ProductSaved());
///
/// // view
/// _subscription = viewModel.events.listen(_onEvent);
/// // ... and cancel it in dispose()
/// ```
///
/// Emitting with no listener drops the event rather than queueing it. A screen
/// that is not on-screen cannot act on anything, and replaying a backlog when
/// it returns is how a user ends up looking at yesterday's error.
class OneShot<T> {
  final _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  bool get hasListener => _controller.hasListener;

  void emit(T event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
