// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class SupplierInfoTask {
  const SupplierInfoTask._();
  const factory SupplierInfoTask() = SupplierInfoIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is SupplierInfoRunning;
  String? get error => switch (this) {
        SupplierInfoFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Supplier? get updated => switch (this) {
        SupplierInfoUpdated(:final result) => result,
        _ => null,
      };
}

final class SupplierInfoIdle extends SupplierInfoTask {
  const SupplierInfoIdle() : super._();
}

final class SupplierInfoRunning extends SupplierInfoTask {
  const SupplierInfoRunning() : super._();
}

final class SupplierInfoUpdated extends SupplierInfoTask {
  final Supplier result;
  const SupplierInfoUpdated(this.result) : super._();
}

final class SupplierInfoFailed extends SupplierInfoTask {
  final Failure failure;
  const SupplierInfoFailed(this.failure) : super._();
}

@immutable
class SupplierInfoState {
  final SupplierInfoTask task;

  final Supplier? supplier;

  const SupplierInfoState({
    this.task = const SupplierInfoIdle(),
    this.supplier,
  });

  bool get saving => task.running;

  String? get error => task.error;

  Supplier? get updated => task.updated;

  SupplierInfoState copyWith({
    SupplierInfoTask? task,
    Supplier? supplier,
  }) {
    return SupplierInfoState(
      task: task ?? this.task,
      supplier: supplier ?? this.supplier,
    );
  }
}
