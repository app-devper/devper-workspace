// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class ReceiveManageState {
  final bool loading;
  final String? error;

  final bool receiveLoaded;
  final Receive? receive;
  final List<Supplier> receiveSuppliers;

  final List<Supplier>? suppliersEvent;

  final bool itemsLoaded;
  final double totalCost;
  final List<ReceiveItem> items;

  final Receive? created;
  final Receive? updated;
  final Receive? removed;
  final ReceiveItem? removedItem;

  const ReceiveManageState({
    this.loading = false,
    this.error,
    this.receiveLoaded = false,
    this.receive,
    this.receiveSuppliers = const [],
    this.suppliersEvent,
    this.itemsLoaded = false,
    this.totalCost = 0,
    this.items = const [],
    this.created,
    this.updated,
    this.removed,
    this.removedItem,
  });

  ReceiveManageState copyWith({
    bool? loading,
    String? error,
    bool? receiveLoaded,
    Receive? receive,
    List<Supplier>? receiveSuppliers,
    List<Supplier>? suppliersEvent,
    bool? itemsLoaded,
    double? totalCost,
    List<ReceiveItem>? items,
    Receive? created,
    Receive? updated,
    Receive? removed,
    ReceiveItem? removedItem,
    bool clearError = false,
    bool clearReceive = false,
    bool clearSuppliersEvent = false,
    bool clearCreated = false,
    bool clearUpdated = false,
    bool clearRemoved = false,
    bool clearRemovedItem = false,
  }) {
    return ReceiveManageState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      receiveLoaded: receiveLoaded ?? this.receiveLoaded,
      receive: clearReceive ? null : (receive ?? this.receive),
      receiveSuppliers: receiveSuppliers ?? this.receiveSuppliers,
      suppliersEvent: clearSuppliersEvent ? null : (suppliersEvent ?? this.suppliersEvent),
      itemsLoaded: itemsLoaded ?? this.itemsLoaded,
      totalCost: totalCost ?? this.totalCost,
      items: items ?? this.items,
      created: clearCreated ? null : (created ?? this.created),
      updated: clearUpdated ? null : (updated ?? this.updated),
      removed: clearRemoved ? null : (removed ?? this.removed),
      removedItem: clearRemovedItem ? null : (removedItem ?? this.removedItem),
    );
  }
}
