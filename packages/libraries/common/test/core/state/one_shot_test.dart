import 'package:common/core/state/one_shot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an event is delivered once, with nothing left to clear', () async {
    final events = OneShot<String>();
    final seen = <String>[];
    events.stream.listen(seen.add);

    events.emit('saved');
    await Future<void>.delayed(Duration.zero);

    expect(seen, ['saved']);

    // The old shape needed a consume() here. Without one it fired again on the
    // next notification; this cannot, because there is nothing holding it.
    await Future<void>.delayed(Duration.zero);
    expect(seen, ['saved']);
  });

  test('events arrive in the order they were emitted', () async {
    final events = OneShot<int>();
    final seen = <int>[];
    events.stream.listen(seen.add);

    events
      ..emit(1)
      ..emit(2)
      ..emit(3);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [1, 2, 3]);
  });

  test('an event with nobody listening is dropped, not queued', () async {
    final events = OneShot<String>();

    events.emit('while off-screen');
    final seen = <String>[];
    events.stream.listen(seen.add);
    await Future<void>.delayed(Duration.zero);

    expect(seen, isEmpty,
        reason: 'a screen returning later must not be shown an old error');
  });

  test('two listeners both see an event', () async {
    final events = OneShot<String>();
    final a = <String>[];
    final b = <String>[];
    events.stream.listen(a.add);
    events.stream.listen(b.add);

    events.emit('x');
    await Future<void>.delayed(Duration.zero);

    expect(a, ['x']);
    expect(b, ['x']);
  });

  test('emitting after dispose is ignored rather than throwing', () async {
    final events = OneShot<String>();
    events.stream.listen((_) {});
    events.dispose();

    expect(() => events.emit('late'), returnsNormally,
        reason: 'a request can outlive the screen that started it');
  });

  test('a cancelled subscription stops delivery', () async {
    final events = OneShot<String>();
    final seen = <String>[];
    final subscription = events.stream.listen(seen.add);

    events.emit('first');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    events.emit('second');
    await Future<void>.delayed(Duration.zero);

    expect(seen, ['first']);
  });
}
