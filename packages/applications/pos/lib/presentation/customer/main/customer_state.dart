// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class CustomerTask {
  const CustomerTask._();
  const factory CustomerTask() = CustomerIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is CustomerRunning;
  String? get error => switch (this) {
        CustomerFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Customer? get loaded => switch (this) {
        CustomerLoaded(:final result) => result,
        _ => null,
      };
}

final class CustomerIdle extends CustomerTask {
  const CustomerIdle() : super._();
}

final class CustomerRunning extends CustomerTask {
  const CustomerRunning() : super._();
}

final class CustomerLoaded extends CustomerTask {
  final Customer result;
  const CustomerLoaded(this.result) : super._();
}

final class CustomerFailed extends CustomerTask {
  final Failure failure;
  const CustomerFailed(this.failure) : super._();
}

@immutable
class CustomerState {
  final CustomerTask task;

  const CustomerState({
    this.task = const CustomerIdle(),
  });

  bool get loading => task.running;

  String? get error => task.error;

  Customer? get loaded => task.loaded;

  CustomerState copyWith({
    CustomerTask? task,
  }) {
    return CustomerState(
      task: task ?? this.task,
    );
  }
}
