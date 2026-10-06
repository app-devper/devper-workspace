// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_products_use_case.dart';
import 'package:pos/presentation/receive/manage/receive_manage_state.dart';

import 'package:pos/domain/repositories/supplier_repository.dart';

import 'package:pos/domain/repositories/receive_repository.dart';

class ReceiveManageViewModel {
  final ReceiveRepository receiveRepo;
  final SupplierRepository supplierRepo;
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;
  final GetProductsUseCase getProductsUseCase;

  ReceiveManageViewModel({
    required this.receiveRepo,
    required this.supplierRepo,
    required this.getLocalProductByIdUseCase,
    required this.getProductsUseCase,
  });

  final _state = ValueNotifier<ReceiveManageState>(const ReceiveManageState());
  final _loaded = OneShot<Receive>();
  final _created = OneShot<Receive>();
  final _updated = OneShot<Receive>();
  final _removed = OneShot<Receive>();
  final _errors = OneShot<String>();

  ValueListenable<ReceiveManageState> get state => _state;

  /// An existing document has arrived, so the form can seed its fields from
  /// it. Only the first load emits — what the page renders afterwards it reads
  /// from state.
  Stream<Receive> get loaded => _loaded.stream;

  /// The document was created, saved, or deleted. Each is a message to show
  /// or a screen to leave, never something drawn.
  Stream<Receive> get created => _created.stream;

  Stream<Receive> get updated => _updated.stream;

  Stream<Receive> get removed => _removed.stream;

  Stream<String> get errors => _errors.stream;

  /// Loads the document, its lines and the supplier options.
  ///
  /// A null id means the user is creating one, so there is nothing to fetch
  /// but the suppliers behind the picker.
  Future<void> getReceiveById(String? receiveId) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final suppliers = await supplierRepo.getLocalSuppliers();
      Receive? receive;
      if (receiveId != null) {
        receive = await receiveRepo.getReceiveById(receiveId);
      }
      _state.value = _state.value.copyWith(
        loading: false,
        receive: receive,
        receiveSuppliers: suppliers,
      );
      if (receive != null) {
        _loaded.emit(receive);
        // Reported on its own, after the document is on screen. It used to run
        // inside this try, where the success written afterwards overwrote the
        // failure and left the user with an empty list and no message.
        await getReceiveItemsById(receiveId!);
      }
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<void> createReceive(ReceiveParam param) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final created = await receiveRepo.createReceive(param);
      _state.value = _state.value
          .copyWith(loading: false, receive: created, itemsReady: true);
      _created.emit(created);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<bool> updateReceiveById(
      String receiveId, UpdateReceiveParam param) async {
    if (_state.value.loading ||
        !_state.value.itemsReady ||
        _state.value.receive?.isImported == true) {
      return false;
    }
    _state.value = _state.value.copyWith(loading: true);
    try {
      final updated = await receiveRepo.updateReceiveById(receiveId, param);
      _state.value = _state.value.copyWith(loading: false, receive: updated);
      _updated.emit(updated);
      await getReceiveItemsById(receiveId);
      return true;
    } on Exception catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<void> removeReceiveById(String receiveId) async {
    if (_state.value.loading || _state.value.receive?.isImported == true) {
      return;
    }
    _state.value = _state.value.copyWith(loading: true);
    try {
      final removed = await receiveRepo.removeReceiveById(receiveId);
      _state.value = _state.value.copyWith(loading: false);
      _removed.emit(removed);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<void> importReceive(String receiveId) async {
    if (_state.value.loading ||
        !_state.value.itemsReady ||
        _state.value.receive?.isImported == true) {
      return;
    }
    _state.value = _state.value.copyWith(loading: true);
    try {
      final imported = await receiveRepo.importReceiveById(receiveId);
      _state.value = _state.value.copyWith(loading: false, receive: imported);
      _updated.emit(imported);
      await getProductsUseCase();
      await getReceiveItemsById(receiveId);
    } on Exception catch (e) {
      _fail(e);
    }
  }

  Future<void> getReceiveItemsById(String receiveId) async {
    _state.value = _state.value.copyWith(itemsReady: false);
    try {
      final result = await receiveRepo.getReceiveItemsById(receiveId);
      for (var item in result) {
        item.product = await getLocalProductByIdUseCase(item.productId);
      }
      _state.value = _state.value.copyWith(
        itemsReady: true,
        totalCost: _calculateTotalCost(result),
        items: result,
      );
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> getSuppliers() async {
    try {
      final suppliers = await supplierRepo.getSuppliers();
      _state.value = _state.value.copyWith(receiveSuppliers: suppliers);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  void _fail(Exception e) {
    _state.value = _state.value.copyWith(loading: false);
    _errors.emit(toFailure(e).getMessage());
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
    _loaded.dispose();
    _created.dispose();
    _updated.dispose();
    _removed.dispose();
    _errors.dispose();
  }
}
