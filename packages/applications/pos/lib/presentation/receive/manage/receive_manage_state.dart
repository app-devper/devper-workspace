// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

/// What this screen renders: the receive document, the supplier options behind
/// its picker, its lines and their total.
///
/// It used to carry three more signals — `receiveLoaded`, `itemsLoaded` and
/// `suppliersEvent` — whose whole job was to tell the page to copy the fields
/// beside them into its own variables. The page reads them here instead.
///
/// The command results (created, updated, removed) and the error are on the
/// channel: a toast, a pop and a snack bar are not things this screen draws.
@immutable
class ReceiveManageState {
  final bool loading;
  final Receive? receive;
  final List<Supplier> receiveSuppliers;
  final double totalCost;
  final List<ReceiveItem> items;

  /// Saving sends the lines back, so a save before they have loaded would
  /// write an empty document. This guards the commands; it does not describe
  /// progress, which is what [loading] is for.
  final bool itemsReady;

  const ReceiveManageState({
    this.loading = false,
    this.receive,
    this.receiveSuppliers = const [],
    this.totalCost = 0,
    this.items = const [],
    this.itemsReady = false,
  });

  ReceiveManageState copyWith({
    bool? loading,
    Receive? receive,
    List<Supplier>? receiveSuppliers,
    double? totalCost,
    List<ReceiveItem>? items,
    bool? itemsReady,
  }) {
    return ReceiveManageState(
      loading: loading ?? this.loading,
      receive: receive ?? this.receive,
      receiveSuppliers: receiveSuppliers ?? this.receiveSuppliers,
      totalCost: totalCost ?? this.totalCost,
      items: items ?? this.items,
      itemsReady: itemsReady ?? this.itemsReady,
    );
  }
}
