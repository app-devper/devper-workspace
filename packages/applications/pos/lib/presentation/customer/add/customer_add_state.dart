// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class CustomerAddTask {
  const CustomerAddTask._();
  const factory CustomerAddTask() = CustomerAddIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is CustomerAddRunning;
  String? get error => switch (this) {
        CustomerAddFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Customer? get created => switch (this) {
        CustomerAddCreated(:final result) => result,
        _ => null,
      };
}

final class CustomerAddIdle extends CustomerAddTask {
  const CustomerAddIdle() : super._();
}

final class CustomerAddRunning extends CustomerAddTask {
  const CustomerAddRunning() : super._();
}

final class CustomerAddCreated extends CustomerAddTask {
  final Customer result;
  const CustomerAddCreated(this.result) : super._();
}

final class CustomerAddFailed extends CustomerAddTask {
  final Failure failure;
  const CustomerAddFailed(this.failure) : super._();
}

@immutable
class CustomerAddState {
  final CustomerAddTask task;

  const CustomerAddState({
    this.task = const CustomerAddIdle(),
  });

  bool get saving => task.running;

  String? get error => task.error;

  Customer? get created => task.created;

  CustomerAddState copyWith({
    CustomerAddTask? task,
  }) {
    return CustomerAddState(
      task: task ?? this.task,
    );
  }
}
