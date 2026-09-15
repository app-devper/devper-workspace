// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/exception.dart';
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
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
  final _errors = OneShot<String>();
  final _removals = OneShot<OrderDetail>();
  final _receipts = OneShot<SupplierResult>();
  final _supplierSetups = OneShot<void>();

  ValueListenable<OrderDetailState> get state => _state;

  /// Something went wrong and the user should be told.
  Stream<String> get errors => _errors.stream;

  /// The order was deleted; the screen has nothing left to show and pops with
  /// the document it removed so the list behind it can drop the row.
  Stream<OrderDetail> get removals => _removals.stream;

  /// Everything needed to print a receipt has been gathered.
  Stream<SupplierResult> get receipts => _receipts.stream;

  /// There is no shop profile to print on a receipt yet, so the user is sent
  /// to create one. This is not a failure — see [getSupplier].
  Stream<void> get supplierSetups => _supplierSetups.stream;

  Future<void> checkLogin() async {
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(isAdmin: role == "ADMIN");
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> getOrderById(String orderId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    await _load(orderId);
  }

  Future<void> removeOrderById(String orderId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final removed = await removeOrderByIdUseCase(orderId);
      _state.value = _state.value.copyWith(loading: false);
      _removals.emit(removed);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  /// Deletes one line and refreshes the document, because every total on the
  /// screen changes with it. The page used to make that second call itself,
  /// after reading a `removedItem` out of state.
  Future<void> removeOrderItem(String orderId, String itemId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      await removeOrderItemByIdUseCase(itemId);
    } on Exception catch (e) {
      _fail(e);
      return;
    }
    await _load(orderId);
  }

  /// Gathers the shop profile and, if the order names one, the customer.
  ///
  /// A customer that cannot be looked up is not worth stopping for — the
  /// receipt can be printed with the name typed in the dialog. A shop profile
  /// that does not exist yet is different: there is a screen for creating one,
  /// so the user goes there. Only a 404 means that. Being offline used to send
  /// them to the same form, where they would find their profile already filled
  /// in and no explanation.
  Future<void> getSupplier(String customerCode) async {
    Customer? customer;
    try {
      final result = await getLocalCustomersUseCase();
      customer =
          result.where((element) => element.code == customerCode).firstOrNull;
    } on Exception catch (_) {}
    try {
      final supplier = await getSupplierInfoUseCase();
      _receipts.emit(SupplierResult(supplier: supplier, customer: customer));
    } on NotFoundException {
      _supplierSetups.emit(null);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  /// Fetches the document without the re-entry guard, so a command already
  /// holding the screen can finish by refreshing what it changed.
  Future<void> _load(String orderId) async {
    try {
      final order = await getOrderByIdUseCase(orderId);
      _state.value = _state.value.copyWith(order: order, loading: false);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  void _fail(Exception e) {
    _state.value = _state.value.copyWith(loading: false);
    _errors.emit(toFailure(e).getMessage());
  }

  void dispose() {
    _state.dispose();
    _errors.dispose();
    _removals.dispose();
    _receipts.dispose();
    _supplierSetups.dispose();
  }
}
