// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class StockCountManageTask {
  const StockCountManageTask._();
  const factory StockCountManageTask() = StockCountManageIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is StockCountManageRunning;
  String? get error => switch (this) {
        StockCountManageFailed(:final failure) => failure.getMessage(),
        StockCountManageRejected(:final message) => message,
        _ => null,
      };
  StockCount? get created => switch (this) {
        StockCountManageCreated(:final result) => result,
        _ => null,
      };
}

final class StockCountManageIdle extends StockCountManageTask {
  const StockCountManageIdle() : super._();
}

final class StockCountManageRunning extends StockCountManageTask {
  const StockCountManageRunning() : super._();
}

final class StockCountManageCreated extends StockCountManageTask {
  final StockCount result;
  const StockCountManageCreated(this.result) : super._();
}

final class StockCountManageFailed extends StockCountManageTask {
  final Failure failure;
  const StockCountManageFailed(this.failure) : super._();
}

/// A message this screen produced itself — a validation or a hand-written
/// fallback — rather than a request that failed.
final class StockCountManageRejected extends StockCountManageTask {
  final String message;
  const StockCountManageRejected(this.message) : super._();
}

@immutable
class StockCountManageState {
  final StockCountManageTask task;

  final StockCount? stockCount;
  final List<StockCountItemParam> items;

  const StockCountManageState({
    this.task = const StockCountManageIdle(),
    this.stockCount,
    this.items = const [],
  });

  bool get loading => task.running;

  String? get error => task.error;

  StockCount? get created => task.created;

  StockCountManageState copyWith({
    StockCountManageTask? task,
    StockCount? stockCount,
    List<StockCountItemParam>? items,
  }) {
    return StockCountManageState(
      task: task ?? this.task,
      stockCount: stockCount ?? this.stockCount,
      items: items ?? this.items,
    );
  }
}
