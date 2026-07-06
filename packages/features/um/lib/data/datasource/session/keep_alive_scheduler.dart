import 'dart:async';

import 'package:common/core/error/exception.dart';
import 'package:flutter/widgets.dart';

class KeepAliveScheduler with WidgetsBindingObserver {
  final Future<void> Function() _onTick;
  final Duration _interval;
  Timer? _timer;
  bool _isStarted = false;

  KeepAliveScheduler({
    required Future<void> Function() onTick,
    Duration interval = const Duration(minutes: 4),
  })  : _onTick = onTick,
        _interval = interval;

  bool get isStarted => _isStarted;

  void start() {
    if (_isStarted) {
      return;
    }
    _isStarted = true;
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void stop() {
    if (!_isStarted) {
      return;
    }
    _isStarted = false;
    WidgetsBinding.instance.removeObserver(this);
    _cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isStarted) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _tick();
      _schedule();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _cancel();
    }
  }

  void _schedule() {
    _cancel();
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    try {
      await _onTick();
    } on AuthException {
      stop();
    } on Exception catch (_) {}
  }
}
