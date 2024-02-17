// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
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

  final _states = StreamController<ReceiveManageState>();

  StreamController<ReceiveManageState> get states => _states;

  void getReceiveById(String? receiveId) async {
    _onLoading();
    try {
      Receive? receive;
      if (receiveId != null) {
        receive = await receiveRepo.getReceiveById(receiveId);
        getReceiveItemsById(receiveId);
      }
      final suppliers = await supplierRepo.getLocalSuppliers();
      _onGetReceive(receive, suppliers);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void createReceive(ReceiveParam param) async {
    _onLoading();
    try {
      final result = await receiveRepo.createReceive(param);
      _onCreateReceive(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateReceiveById(String receiveId, UpdateReceiveParam param) async {
    _onLoading();
    try {
      final result = await receiveRepo.updateReceiveById(receiveId, param);
      _onEditReceive(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeReceiveById(String receiveId) async {
    _onLoading();
    try {
      final result = await receiveRepo.removeReceiveById(receiveId);
      _onRemoveReceive(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeReceiveItemById(String lotId) async {
    _onLoading();
    try {
      final result = await receiveRepo.removeReceiveItemByLotId(lotId);
      _onRemoveReceiveItem(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getReceiveItemsById(String receiveId) async {
    try {
      final result = await receiveRepo.getReceiveItemsById(receiveId);
      for (var item in result) {
        item.product = await productRepo.getLocalProductById(item.productId);
      }
      _onGetReceiveItems(result);
    } on Exception catch (_) {}
  }

  void getSuppliers() async {
    try {
      final result = await supplierRepo.getSuppliers();
      _onGetSuppliers(result);
    } on Exception catch (_) {}
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onRemoveReceive(Receive data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveReceiveState(data: data));
    }
  }

  _onRemoveReceiveItem(ReceiveItem data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveReceiveItemState(data: data));
    }
  }

  _onGetReceive(Receive? data, List<Supplier> suppliers) {
    if (!_states.isClosed) {
      _states.sink.add(GetReceiveState(
        data: data,
        suppliers: suppliers,
      ));
    }
  }

  _onCreateReceive(Receive data) {
    if (!_states.isClosed) {
      _states.sink.add(CreateReceiveState(data: data));
    }
  }

  _onEditReceive(Receive data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateReceiveState(data: data));
    }
  }

  _onGetReceiveItems(List<ReceiveItem> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetReceiveItemsState(
        totalCost: _calculateTotalCost(data),
        data: data,
      ));
    }
  }

  _onGetSuppliers(List<Supplier> suppliers) {
    if (!_states.isClosed) {
      _states.sink.add(GetSuppliersState(suppliers: suppliers));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
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

  dispose() {
    _states.close();
  }
}
