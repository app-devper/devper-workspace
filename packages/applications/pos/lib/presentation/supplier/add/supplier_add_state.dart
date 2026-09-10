// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class SupplierAddTask {
  const SupplierAddTask._();
  const factory SupplierAddTask() = SupplierAddIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is SupplierAddRunning;
  String? get error => switch (this) {
        SupplierAddFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Supplier? get created => switch (this) {
        SupplierAddCreated(:final result) => result,
        _ => null,
      };
}

final class SupplierAddIdle extends SupplierAddTask {
  const SupplierAddIdle() : super._();
}

final class SupplierAddRunning extends SupplierAddTask {
  const SupplierAddRunning() : super._();
}

final class SupplierAddCreated extends SupplierAddTask {
  final Supplier result;
  const SupplierAddCreated(this.result) : super._();
}

final class SupplierAddFailed extends SupplierAddTask {
  final Failure failure;
  const SupplierAddFailed(this.failure) : super._();
}

@immutable
class SupplierAddState {
  final SupplierAddTask task;

  const SupplierAddState({
    this.task = const SupplierAddIdle(),
  });

  bool get saving => task.running;

  String? get error => task.error;

  Supplier? get created => task.created;

  SupplierAddState copyWith({
    SupplierAddTask? task,
  }) {
    return SupplierAddState(
      task: task ?? this.task,
    );
  }
}
