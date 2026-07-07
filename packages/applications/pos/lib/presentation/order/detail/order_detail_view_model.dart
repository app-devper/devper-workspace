// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'order_detail_state.dart';

class OrderDetailViewModel {
  final OrderRepository orderRepo;
  final LoginRepository loginRepo;
  final SupplierRepository supplierRepo;
  final CustomerRepository customerRepo;

  OrderDetailViewModel({
    required this.orderRepo,
    required this.loginRepo,
    required this.supplierRepo,
    required this.customerRepo,
  });

  final _state = ValueNotifier<OrderDetailState>(const OrderDetailState());

  ValueListenable<OrderDetailState> get state => _state;

  Future<void> checkLogin() async {
    try {
      final role = await loginRepo.getRole();
      _state.value = _state.value.copyWith(logged: role == "ADMIN");
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> getOrderById(String orderId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final loaded = await orderRepo.getOrderById(orderId);
      _state.value = _state.value.copyWith(loading: false, loaded: loaded);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeOrderById(String orderId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemovedOrder: true);
    try {
      final removed = await orderRepo.removeOrderById(orderId);
      _state.value = _state.value.copyWith(loading: false, removedOrder: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeOrderItem(String id) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemovedItem: true);
    try {
      final removed = await orderRepo.removeOrderItemById(id);
      _state.value = _state.value.copyWith(loading: false, removedItem: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void updateTotalCost() {
    _state.value = _state.value.copyWith(totalCostUpdated: true);
  }

  Future<void> getSupplier(String customerCode) async {
    Customer? customer;
    try {
      final result = await customerRepo.getLocalCustomers();
      customer = result.where((element) => element.code == customerCode).firstOrNull;
    } on Exception catch (_) {}
    try {
      final supplier = await supplierRepo.getSupplierInfo();
      _state.value = _state.value.copyWith(
        supplierResult: SupplierResult(supplier: supplier, customer: customer),
      );
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(supplierError: toFailure(e).getMessage());
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
