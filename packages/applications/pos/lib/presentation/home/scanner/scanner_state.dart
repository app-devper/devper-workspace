// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ScannerTask {
  const ScannerTask._();
  const factory ScannerTask() = ScannerIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ScannerRunning;
  String? get error => switch (this) {
        ScannerFailed(:final failure) => failure.getMessage(),
        ScannerRejected(:final message) => message,
        _ => null,
      };
  Product? get loaded => switch (this) {
        ScannerLoaded(:final result) => result,
        _ => null,
      };
}

final class ScannerIdle extends ScannerTask {
  const ScannerIdle() : super._();
}

final class ScannerRunning extends ScannerTask {
  const ScannerRunning() : super._();
}

final class ScannerLoaded extends ScannerTask {
  final Product result;
  const ScannerLoaded(this.result) : super._();
}

final class ScannerFailed extends ScannerTask {
  final Failure failure;
  const ScannerFailed(this.failure) : super._();
}

/// A message this screen produced itself — a validation or a hand-written
/// fallback — rather than a request that failed.
final class ScannerRejected extends ScannerTask {
  final String message;
  const ScannerRejected(this.message) : super._();
}

@immutable
class ScannerState {
  final ScannerTask task;

  const ScannerState({
    this.task = const ScannerIdle(),
  });

  bool get loading => task.running;

  String? get error => task.error;

  Product? get loaded => task.loaded;

  ScannerState copyWith({
    ScannerTask? task,
  }) {
    return ScannerState(
      task: task ?? this.task,
    );
  }
}
