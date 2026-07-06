// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/receive/manage/receive_manage_state.dart';

class ReceiveManageViewModel {
  final ProductRepository productRepo;
  final SupplierRepository supplierRepo;
  final ReceiveRepository receiveRepo;

  ReceiveManageViewModel({
    required this.productRepo,
    required this.receiveRepo,
    required this.supplierRepo,
  });

  final _state = ValueNotifier<ReceiveManageState>(const ReceiveManageState());

  ValueListenable<ReceiveManageState> get state => _state;

  Future<void> getReceiveById(String? receiveId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      Receive? receive;
      if (receiveId != null) {
        receive = await receiveRepo.getReceiveById(receiveId);
        getReceiveItemsById(receiveId);
      }
      final suppliers = await supplierRepo.getLocalSuppliers();
      _state.value = _state.value.copyWith(
        loading: false,
        receiveLoaded: true,
        receive: receive,
        clearReceive: receive == null,
        receiveSuppliers: suppliers,
      );
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> createReceive(ReceiveParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearCreated: true);
    try {
      final created = await receiveRepo.createReceive(param);
      _state.value = _state.value.copyWith(loading: false, created: created, receive: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> updateReceiveById(String receiveId, UpdateReceiveParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await receiveRepo.updateReceiveById(receiveId, param);
      _state.value = _state.value.copyWith(loading: false, updated: updated, receive: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeReceiveById(String receiveId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await receiveRepo.removeReceiveById(receiveId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeReceiveItemById(String lotId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemovedItem: true);
    try {
      final removedItem = await receiveRepo.removeReceiveItemByLotId(lotId);
      _state.value = _state.value.copyWith(loading: false, removedItem: removedItem);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> getReceiveItemsById(String receiveId) async {
    try {
      final result = await receiveRepo.getReceiveItemsById(receiveId);
      for (var item in result) {
        item.product = await productRepo.getLocalProductById(item.productId);
      }
      _state.value = _state.value.copyWith(
        itemsLoaded: true,
        totalCost: _calculateTotalCost(result),
        items: result,
      );
    } on Exception catch (_) {}
  }

  Future<void> getSuppliers() async {
    try {
      final suppliers = await supplierRepo.getSuppliers();
      _state.value = _state.value.copyWith(suppliersEvent: suppliers);
    } on Exception catch (_) {}
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeReceiveLoaded() {
    if (_state.value.receiveLoaded) {
      _state.value = _state.value.copyWith(receiveLoaded: false);
    }
  }

  void consumeSuppliersEvent() {
    if (_state.value.suppliersEvent != null) {
      _state.value = _state.value.copyWith(clearSuppliersEvent: true);
    }
  }

  void consumeItemsLoaded() {
    if (_state.value.itemsLoaded) {
      _state.value = _state.value.copyWith(itemsLoaded: false);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void consumeRemoved() {
    if (_state.value.removed != null) {
      _state.value = _state.value.copyWith(clearRemoved: true);
    }
  }

  void consumeRemovedItem() {
    if (_state.value.removedItem != null) {
      _state.value = _state.value.copyWith(clearRemovedItem: true);
    }
  }

  double _calculateTotalCost(List<ReceiveItem> data) {
    double total = 0;
    for (var x in data) {
      if (x.quantity > 0) {
        total += x.costPrice * x.quantity;
      }
    }
    return total;
  }

  void dispose() {
    _state.dispose();
  }
}
