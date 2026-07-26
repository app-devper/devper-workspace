// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/usecase/auth/get_role_use_case.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/domain/usecase/order/get_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_item_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'order_detail_state.dart';

class OrderDetailViewModel {
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final RemoveOrderByIdUseCase removeOrderByIdUseCase;
  final RemoveOrderItemByIdUseCase removeOrderItemByIdUseCase;
  final GetRoleUseCase getRoleUseCase;
  final GetSupplierInfoUseCase getSupplierInfoUseCase;
  final GetLocalCustomersUseCase getLocalCustomersUseCase;

  OrderDetailViewModel({
    required this.getOrderByIdUseCase,
    required this.removeOrderByIdUseCase,
    required this.removeOrderItemByIdUseCase,
    required this.getRoleUseCase,
    required this.getSupplierInfoUseCase,
    required this.getLocalCustomersUseCase,
  });

  final _state = ValueNotifier<OrderDetailState>(const OrderDetailState());

  ValueListenable<OrderDetailState> get state => _state;

  Future<void> checkLogin() async {
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(logged: role == "ADMIN");
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> getOrderById(String orderId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final loaded = await getOrderByIdUseCase(orderId);
      _state.value = _state.value.copyWith(loading: false, loaded: loaded);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeOrderById(String orderId) async {
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearRemovedOrder: true);
    try {
      final removed = await removeOrderByIdUseCase(orderId);
      _state.value =
          _state.value.copyWith(loading: false, removedOrder: removed);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeOrderItem(String id) async {
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearRemovedItem: true);
    try {
      final removed = await removeOrderItemByIdUseCase(id);
      _state.value =
          _state.value.copyWith(loading: false, removedItem: removed);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void updateTotalCost() {
    _state.value = _state.value.copyWith(totalCostUpdated: true);
  }

  Future<void> getSupplier(String customerCode) async {
    Customer? customer;
    try {
      final result = await getLocalCustomersUseCase();
      customer =
          result.where((element) => element.code == customerCode).firstOrNull;
    } on Exception catch (_) {}
    try {
      final supplier = await getSupplierInfoUseCase();
      _state.value = _state.value.copyWith(
        supplierResult: SupplierResult(supplier: supplier, customer: customer),
      );
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(supplierError: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeLogged() {
    if (_state.value.logged != null) {
      _state.value = _state.value.copyWith(clearLogged: true);
    }
  }

  void consumeLoaded() {
    if (_state.value.loaded != null) {
      _state.value = _state.value.copyWith(clearLoaded: true);
    }
  }

  void consumeRemovedOrder() {
    if (_state.value.removedOrder != null) {
      _state.value = _state.value.copyWith(clearRemovedOrder: true);
    }
  }

  void consumeRemovedItem() {
    if (_state.value.removedItem != null) {
      _state.value = _state.value.copyWith(clearRemovedItem: true);
    }
  }

  void consumeTotalCostUpdated() {
    if (_state.value.totalCostUpdated) {
      _state.value = _state.value.copyWith(clearTotalCostUpdated: true);
    }
  }

  void consumeSupplierResult() {
    if (_state.value.supplierResult != null) {
      _state.value = _state.value.copyWith(clearSupplierResult: true);
    }
  }

  void consumeSupplierError() {
    if (_state.value.supplierError != null) {
      _state.value = _state.value.copyWith(clearSupplierError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
