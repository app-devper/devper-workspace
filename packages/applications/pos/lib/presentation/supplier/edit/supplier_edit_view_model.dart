// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_state.dart';

class SupplierEditViewModel {
  final SupplierRepository supplierRepo;

  SupplierEditViewModel({
    required this.supplierRepo,
  });

  final _states = StreamController<SupplierEditState>();

  Stream<SupplierEditState> get states => _states.stream;

  getSupplier(Supplier result) async {
    try {
      _onGetSupplier(result);
    } on Exception catch (_) {
    }
  }

  updateSupplierById(String supplierId, SupplierParam param) async {
    _onLoading();
    try {
      final result = await supplierRepo.updateSupplierById(supplierId, param);
      _onEditSupplier(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  removeSupplierById(String supplierId) async {
    _onLoading();
    try {
      final result = await supplierRepo.removeSupplierById(supplierId);
      _onRemoveSupplier(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onRemoveSupplier(Supplier data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveSupplierState(data: data));
    }
  }

  _onGetSupplier(Supplier data) {
    if (!_states.isClosed) {
      _states.sink.add(GetSupplierState(data: data));
    }
  }

  _onEditSupplier(Supplier data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateSupplierState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
