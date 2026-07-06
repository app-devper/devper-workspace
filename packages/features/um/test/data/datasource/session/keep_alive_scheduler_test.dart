import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um/data/datasource/session/keep_alive_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ticks periodically after start', () async {
    var ticks = 0;
    final scheduler = KeepAliveScheduler(
      onTick: () async {
        ticks = ticks + 1;
      },
      interval: const Duration(milliseconds: 20),
    );

    scheduler.start();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    scheduler.stop();

    expect(ticks, greaterThanOrEqualTo(2));
  });

  test('stops itself when a tick throws AuthException', () async {
    var ticks = 0;
    final scheduler = KeepAliveScheduler(
      onTick: () async {
        ticks = ticks + 1;
        throw const AuthException(message: 'expired');
      },
      interval: const Duration(milliseconds: 20),
    );

    scheduler.start();
    await Future<void>.delayed(const Duration(milliseconds: 90));

    expect(ticks, 1);
    expect(scheduler.isStarted, isFalse);
  });

  test('keeps running when a tick throws a transient error', () async {
    var ticks = 0;
    final scheduler = KeepAliveScheduler(
      onTick: () async {
        ticks = ticks + 1;
        throw const NetworkException(message: 'offline');
      },
      interval: const Duration(milliseconds: 20),
    );

    scheduler.start();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    scheduler.stop();

    expect(ticks, greaterThanOrEqualTo(2));
    expect(scheduler.isStarted, isFalse);
  });

  test('start is idempotent', () async {
    var ticks = 0;
    final scheduler = KeepAliveScheduler(
      onTick: () async {
        ticks = ticks + 1;
      },
      interval: const Duration(milliseconds: 30),
    );

    scheduler.start();
    scheduler.start();
    await Future<void>.delayed(const Duration(milliseconds: 45));
    scheduler.stop();

    expect(ticks, 1);
  });
}
