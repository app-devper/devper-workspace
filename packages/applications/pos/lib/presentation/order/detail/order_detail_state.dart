// Flutter imports:
import 'package:flutter/foundation.dart';

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

@immutable
class OrderDetailState {
  final bool loading;
  final String? error;
  final bool? logged;
  final OrderDetail? loaded;
  final OrderDetail? removedOrder;
  final OrderItemDetail? removedItem;
  final bool totalCostUpdated;
  final SupplierResult? supplierResult;
  final String? supplierError;

  const OrderDetailState({
    this.loading = false,
    this.error,
    this.logged,
    this.loaded,
    this.removedOrder,
    this.removedItem,
    this.totalCostUpdated = false,
    this.supplierResult,
    this.supplierError,
  });

  OrderDetailState copyWith({
    bool? loading,
    String? error,
    bool? logged,
    OrderDetail? loaded,
    OrderDetail? removedOrder,
    OrderItemDetail? removedItem,
    bool? totalCostUpdated,
    SupplierResult? supplierResult,
    String? supplierError,
    bool clearError = false,
    bool clearLogged = false,
    bool clearLoaded = false,
    bool clearRemovedOrder = false,
    bool clearRemovedItem = false,
    bool clearTotalCostUpdated = false,
    bool clearSupplierResult = false,
    bool clearSupplierError = false,
  }) {
    return OrderDetailState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      logged: clearLogged ? null : (logged ?? this.logged),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
      removedOrder: clearRemovedOrder ? null : (removedOrder ?? this.removedOrder),
      removedItem: clearRemovedItem ? null : (removedItem ?? this.removedItem),
      totalCostUpdated: clearTotalCostUpdated ? false : (totalCostUpdated ?? this.totalCostUpdated),
      supplierResult: clearSupplierResult ? null : (supplierResult ?? this.supplierResult),
      supplierError: clearSupplierError ? null : (supplierError ?? this.supplierError),
    );
  }
}
