// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

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
      _state.value = _state.value.copyWith(task: OrderTaskFailed(toFailure(e)));
    }
  }

  Future<void> getOrderById(String orderId) async {
    if (_state.value.task is OrderTaskRunning) return;
    _state.value = _state.value.copyWith(task: const OrderTaskRunning());
    try {
      final loaded = await getOrderByIdUseCase(orderId);
      _state.value = _state.value.copyWith(task: OrderLoaded(loaded));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(task: OrderTaskFailed(toFailure(e)));
    }
  }

  Future<void> removeOrderById(String orderId) async {
    if (_state.value.task is OrderTaskRunning) return;
    _state.value = _state.value.copyWith(task: const OrderTaskRunning());
    try {
      final removed = await removeOrderByIdUseCase(orderId);
      _state.value = _state.value.copyWith(task: OrderRemoved(removed));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(task: OrderTaskFailed(toFailure(e)));
    }
  }

  Future<void> removeOrderItem(String id) async {
    if (_state.value.task is OrderTaskRunning) return;
    _state.value = _state.value.copyWith(task: const OrderTaskRunning());
    try {
      final removed = await removeOrderItemByIdUseCase(id);
      _state.value = _state.value.copyWith(task: OrderItemRemoved(removed));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(task: OrderTaskFailed(toFailure(e)));
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
        supplier: SupplierFound(
          SupplierResult(supplier: supplier, customer: customer),
        ),
      );
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(supplier: SupplierNotConfigured(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is OrderTaskFailed) {
      _state.value = _state.value.copyWith(task: const OrderTask());
    }
  }

  void consumeLogged() {
    if (_state.value.logged != null) {
      _state.value = _state.value.copyWith(clearLogged: true);
    }
  }

  void consumeLoaded() {
    if (_state.value.task is OrderLoaded) {
      _state.value = _state.value.copyWith(task: const OrderTask());
    }
  }

  void consumeRemovedOrder() {
    if (_state.value.task is OrderRemoved) {
      _state.value = _state.value.copyWith(task: const OrderTask());
    }
  }

  void consumeRemovedItem() {
    if (_state.value.task is OrderItemRemoved) {
      _state.value = _state.value.copyWith(task: const OrderTask());
    }
  }

  void consumeTotalCostUpdated() {
    if (_state.value.totalCostUpdated) {
      _state.value = _state.value.copyWith(clearTotalCostUpdated: true);
    }
  }

  void consumeSupplierResult() {
    if (_state.value.supplier is SupplierFound) {
      _state.value = _state.value.copyWith(supplier: const SupplierLookup());
    }
  }

  void consumeSupplierError() {
    if (_state.value.supplier is SupplierNotConfigured) {
      _state.value = _state.value.copyWith(supplier: const SupplierLookup());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
