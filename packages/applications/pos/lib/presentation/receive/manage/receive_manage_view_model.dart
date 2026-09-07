// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_products_use_case.dart';
import 'package:pos/domain/usecase/receive/create_receive_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_items_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/remove_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/import_receive_use_case.dart';
import 'package:pos/domain/usecase/receive/update_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_local_suppliers_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_suppliers_use_case.dart';
import 'package:pos/presentation/receive/manage/receive_manage_state.dart';

class ReceiveManageViewModel {
  final GetReceiveByIdUseCase getReceiveByIdUseCase;
  final CreateReceiveUseCase createReceiveUseCase;
  final UpdateReceiveByIdUseCase updateReceiveByIdUseCase;
  final RemoveReceiveByIdUseCase removeReceiveByIdUseCase;
  final GetReceiveItemsByIdUseCase getReceiveItemsByIdUseCase;
  final ImportReceiveUseCase importReceiveUseCase;
  final GetLocalSuppliersUseCase getLocalSuppliersUseCase;
  final GetSuppliersUseCase getSuppliersUseCase;
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;
  final GetProductsUseCase getProductsUseCase;

  ReceiveManageViewModel({
    required this.getReceiveByIdUseCase,
    required this.createReceiveUseCase,
    required this.updateReceiveByIdUseCase,
    required this.removeReceiveByIdUseCase,
    required this.getReceiveItemsByIdUseCase,
    required this.importReceiveUseCase,
    required this.getLocalSuppliersUseCase,
    required this.getSuppliersUseCase,
    required this.getLocalProductByIdUseCase,
    required this.getProductsUseCase,
  });

  final _state = ValueNotifier<ReceiveManageState>(const ReceiveManageState());

  ValueListenable<ReceiveManageState> get state => _state;

  Future<void> getReceiveById(String? receiveId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      Receive? receive;
      if (receiveId != null) {
        receive = await getReceiveByIdUseCase(receiveId);
        await getReceiveItemsById(receiveId);
      }
      final suppliers = await getLocalSuppliersUseCase();
      _state.value = _state.value.copyWith(
        loading: false,
        receiveLoaded: true,
        receive: receive,
        clearReceive: receive == null,
        receiveSuppliers: suppliers,
      );
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> createReceive(ReceiveParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearCreated: true);
    try {
      final created = await createReceiveUseCase(param);
      _state.value = _state.value.copyWith(
          loading: false, created: created, receive: created, itemsReady: true);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<bool> updateReceiveById(
      String receiveId, UpdateReceiveParam param) async {
    if (_state.value.loading ||
        !_state.value.itemsReady ||
        _state.value.receive?.isImported == true) {
      return false;
    }
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateReceiveByIdUseCase(
        ReceiveUpdateParam(receiveId: receiveId, param: param),
      );
      _state.value = _state.value
          .copyWith(loading: false, updated: updated, receive: updated);
      await getReceiveItemsById(receiveId);
      return true;
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
      return false;
    }
  }

  Future<void> removeReceiveById(String receiveId) async {
    if (_state.value.loading || _state.value.receive?.isImported == true) {
      return;
    }
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await removeReceiveByIdUseCase(receiveId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> importReceive(String receiveId) async {
    if (_state.value.loading ||
        !_state.value.itemsReady ||
        _state.value.receive?.isImported == true) {
      return;
    }
    _state.value = _state.value
        .copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final imported = await importReceiveUseCase(receiveId);
      _state.value = _state.value
          .copyWith(loading: false, updated: imported, receive: imported);
      await getProductsUseCase();
      await getReceiveItemsById(receiveId);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> getReceiveItemsById(String receiveId) async {
    _state.value = _state.value.copyWith(itemsReady: false);
    try {
      final result = await getReceiveItemsByIdUseCase(receiveId);
      for (var item in result) {
        item.product = await getLocalProductByIdUseCase(item.productId);
      }
      _state.value = _state.value.copyWith(
        itemsLoaded: true,
        itemsReady: true,
        totalCost: _calculateTotalCost(result),
        items: result,
      );
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> getSuppliers() async {
    try {
      final suppliers = await getSuppliersUseCase();
      _state.value = _state.value.copyWith(suppliersEvent: suppliers);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
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
