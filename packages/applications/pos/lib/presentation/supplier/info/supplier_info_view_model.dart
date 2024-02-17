// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/info/supplier_info_state.dart';

class SupplierInfoViewModel {
  final SupplierRepository supplierRepo;

  SupplierInfoViewModel({
    required this.supplierRepo,
  });

  final _states = StreamController<SupplierInfoState>();

  Stream<SupplierInfoState> get states => _states.stream;

  void getSupplierInfo() async {
    try {
      final result = await supplierRepo.getSupplierInfo();
      _onGetSupplier(result);
    } on Exception catch (_) {}
  }

  void updateSupplierInfo(SupplierParam param) async {
    _onLoading();
    try {
      final result = await supplierRepo.updateSupplierInfo(param);
      _onUpdateSupplier(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onGetSupplier(Supplier data) {
    if (!_states.isClosed) {
      _states.sink.add(GetSupplierState(data: data));
    }
  }

  _onUpdateSupplier(Supplier data) {
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
