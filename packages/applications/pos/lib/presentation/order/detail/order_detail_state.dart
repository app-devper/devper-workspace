// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SupplierResult {
  final Supplier supplier;
  final Customer? customer;

  const SupplierResult({
    required this.supplier,
    required this.customer,
  });
}

/// The order document's command family: loading it, deleting it, and deleting
/// one of its items.
///
/// The three produce different results and never coexist, so they share one
/// slot rather than three nullable fields that could all be set at once.
sealed class OrderTask {
  const OrderTask._();
  const factory OrderTask() = OrderTaskIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is OrderTaskRunning;
  String? get error => switch (this) {
        OrderTaskFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  OrderDetail? get loaded => switch (this) {
        OrderLoaded(:final order) => order,
        _ => null,
      };
  OrderDetail? get removedOrder => switch (this) {
        OrderRemoved(:final order) => order,
        _ => null,
      };
  OrderItemDetail? get removedItem => switch (this) {
        OrderItemRemoved(:final item) => item,
        _ => null,
      };
}

final class OrderTaskIdle extends OrderTask {
  const OrderTaskIdle() : super._();
}

final class OrderTaskRunning extends OrderTask {
  const OrderTaskRunning() : super._();
}

final class OrderLoaded extends OrderTask {
  final OrderDetail order;
  const OrderLoaded(this.order) : super._();
}

final class OrderRemoved extends OrderTask {
  final OrderDetail order;
  const OrderRemoved(this.order) : super._();
}

final class OrderItemRemoved extends OrderTask {
  final OrderItemDetail item;
  const OrderItemRemoved(this.item) : super._();
}

/// The screen's one error channel. The role probe reports here too, as it did
/// before this was a sealed type.
final class OrderTaskFailed extends OrderTask {
  final Failure failure;
  const OrderTaskFailed(this.failure) : super._();
}

/// Looking up the shop's supplier profile before printing a receipt.
///
/// A missing profile is not a failure to report — the screen sends the user to
/// set one up — so the variant says that rather than hiding it in an "error".
sealed class SupplierLookup {
  const SupplierLookup._();
  const factory SupplierLookup() = SupplierLookupIdle;

  SupplierResult? get result => switch (this) {
        SupplierFound(:final profile) => profile,
        _ => null,
      };
  String? get error => switch (this) {
        SupplierNotConfigured(:final failure) => failure.getMessage(),
        _ => null,
      };
}

final class SupplierLookupIdle extends SupplierLookup {
  const SupplierLookupIdle() : super._();
}

final class SupplierFound extends SupplierLookup {
  final SupplierResult profile;
  const SupplierFound(this.profile) : super._();
}

final class SupplierNotConfigured extends SupplierLookup {
  final Failure failure;
  const SupplierNotConfigured(this.failure) : super._();
}

@immutable
class OrderDetailState {
  final OrderTask task;
  final SupplierLookup supplier;

  /// A one-shot delivery of the role probe's answer, and a one-shot request to
  /// reload after the total cost was recalculated. Neither is a command flag.
  final bool? logged;
  final bool totalCostUpdated;

  const OrderDetailState({
    this.task = const OrderTaskIdle(),
    this.supplier = const SupplierLookupIdle(),
    this.logged,
    this.totalCostUpdated = false,
  });

  bool get loading => task.running;

  String? get error => task.error;

  OrderDetail? get loaded => task.loaded;

  OrderDetail? get removedOrder => task.removedOrder;

  OrderItemDetail? get removedItem => task.removedItem;

  SupplierResult? get supplierResult => supplier.result;

  String? get supplierError => supplier.error;

  OrderDetailState copyWith({
    OrderTask? task,
    SupplierLookup? supplier,
    bool? logged,
    bool? totalCostUpdated,
    bool clearLogged = false,
    bool clearTotalCostUpdated = false,
  }) {
    return OrderDetailState(
      task: task ?? this.task,
      supplier: supplier ?? this.supplier,
      logged: clearLogged ? null : (logged ?? this.logged),
      totalCostUpdated: clearTotalCostUpdated
          ? false
          : (totalCostUpdated ?? this.totalCostUpdated),
    );
  }
}
