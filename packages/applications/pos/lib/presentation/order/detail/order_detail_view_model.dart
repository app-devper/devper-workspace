// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
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

  final _states = StreamController<OrderDetailState>();

  StreamController<OrderDetailState> get states => _states;

  void checkLogin() async {
    try {
      final result = await loginRepo.getRole();
      _onCheckLogin(result == "ADMIN");
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getOrderById(String orderId) async {
    _onLoading();
    try {
      final result = await orderRepo.getOrderById(orderId);
      _onGetOrder(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeOrderById(String orderId) async {
    _onLoading();
    try {
      final result = await orderRepo.removeOrderById(orderId);
      _onRemoveOrder(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeOrderItem(String id) async {
    _onLoading();
    try {
      final result = await orderRepo.removeOrderItemById(id);
      _onRemoveOrderItem(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateTotalCost() {
    _onLoading();
    _onUpdateTotalCost();
  }

  void getSupplier(String customerCode) async {
    Customer? customer;
    try {
      final result = await customerRepo.getLocalCustomers();
      customer =
          result.where((element) => element.code == customerCode).firstOrNull;
    } on Exception catch (_) {}
    try {
      final result = await supplierRepo.getSupplierInfo();
      _onGetSupplier(result, customer);
    } on Exception catch (e) {
      _onGetSupplierError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCheckLogin(bool isLogin) {
    if (!_states.isClosed) {
      _states.sink.add((LoggedState(isLogin)));
    }
  }

  _onGetOrder(OrderDetail order) {
    if (!_states.isClosed) {
      _states.sink.add(OrderState(order));
    }
  }

  _onRemoveOrder(OrderDetail order) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveOrderState(order));
    }
  }

  _onRemoveOrderItem(OrderItemDetail orderItem) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveOrderItemState(orderItem));
    }
  }

  _onUpdateTotalCost() {
    if (!_states.isClosed) {
      _states.sink.add(UpdateTotalCostState());
    }
  }

  _onGetSupplier(Supplier supplier, Customer? customer) {
    if (!_states.isClosed) {
      _states.sink.add(GetSupplierState(
        supplier: supplier,
        customer: customer,
      ));
    }
  }

  _onGetSupplierError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(GetSupplierErrorState(failure.getMessage()));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
