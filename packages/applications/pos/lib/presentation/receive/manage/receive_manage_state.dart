// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

/// The receive document's commands: create it, save it, delete it, import it.
///
/// The three outcomes are mutually exclusive — one command runs at a time and
/// produces one result — so they share a slot rather than sitting in three
/// nullable fields that nothing stopped from all being set at once.
///
/// This is also the screen's single error channel: loading the document, its
/// items and the supplier list all report here, as they did before.
sealed class ReceiveTask {
  const ReceiveTask._();
  const factory ReceiveTask() = ReceiveTaskIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ReceiveTaskRunning;
  String? get error => switch (this) {
        ReceiveTaskFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Receive? get created => switch (this) {
        ReceiveCreated(:final receive) => receive,
        _ => null,
      };
  Receive? get updated => switch (this) {
        ReceiveUpdated(:final receive) => receive,
        _ => null,
      };
  Receive? get removed => switch (this) {
        ReceiveRemoved(:final receive) => receive,
        _ => null,
      };
}

final class ReceiveTaskIdle extends ReceiveTask {
  const ReceiveTaskIdle() : super._();
}

final class ReceiveTaskRunning extends ReceiveTask {
  const ReceiveTaskRunning() : super._();
}

final class ReceiveCreated extends ReceiveTask {
  final Receive receive;
  const ReceiveCreated(this.receive) : super._();
}

/// Saving and importing both land here: the page treats them the same way.
final class ReceiveUpdated extends ReceiveTask {
  final Receive receive;
  const ReceiveUpdated(this.receive) : super._();
}

final class ReceiveRemoved extends ReceiveTask {
  final Receive receive;
  const ReceiveRemoved(this.receive) : super._();
}

final class ReceiveTaskFailed extends ReceiveTask {
  final Failure failure;
  const ReceiveTaskFailed(this.failure) : super._();
}

@immutable
class ReceiveManageState {
  final ReceiveTask task;

  /// What the screen renders: the document, the supplier options behind its
  /// picker, and its lines. Data, not flags.
  final Receive? receive;
  final List<Supplier> receiveSuppliers;
  final double totalCost;
  final List<ReceiveItem> items;

  /// Saving requires the lines to have loaded, so this guards the commands
  /// rather than describing progress.
  final bool itemsReady;

  /// One-shot signals telling the view to pick data up. Each is a single
  /// notification, not a command with flags.
  final bool receiveLoaded;
  final bool itemsLoaded;
  final List<Supplier>? suppliersEvent;

  const ReceiveManageState({
    this.task = const ReceiveTaskIdle(),
    this.receive,
    this.receiveSuppliers = const [],
    this.totalCost = 0,
    this.items = const [],
    this.itemsReady = false,
    this.receiveLoaded = false,
    this.itemsLoaded = false,
    this.suppliersEvent,
  });

  bool get loading => task.running;

  String? get error => task.error;

  Receive? get created => task.created;

  Receive? get updated => task.updated;

  Receive? get removed => task.removed;

  ReceiveManageState copyWith({
    ReceiveTask? task,
    Receive? receive,
    List<Supplier>? receiveSuppliers,
    double? totalCost,
    List<ReceiveItem>? items,
    bool? itemsReady,
    bool? receiveLoaded,
    bool? itemsLoaded,
    List<Supplier>? suppliersEvent,
    bool clearReceive = false,
    bool clearSuppliersEvent = false,
  }) {
    return ReceiveManageState(
      task: task ?? this.task,
      receive: clearReceive ? null : (receive ?? this.receive),
      receiveSuppliers: receiveSuppliers ?? this.receiveSuppliers,
      totalCost: totalCost ?? this.totalCost,
      items: items ?? this.items,
      itemsReady: itemsReady ?? this.itemsReady,
      receiveLoaded: receiveLoaded ?? this.receiveLoaded,
      itemsLoaded: itemsLoaded ?? this.itemsLoaded,
      suppliersEvent:
          clearSuppliersEvent ? null : (suppliersEvent ?? this.suppliersEvent),
    );
  }
}
