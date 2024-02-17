// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/add/supplier_add_state.dart';

class SupplierAddViewModel {
  final SupplierRepository supplierRepo;

  SupplierAddViewModel({
    required this.supplierRepo,
  });

  final _states = StreamController<SupplierAddState>();

  Stream<SupplierAddState> get states => _states.stream;

  void createSupplier(SupplierParam param) async {
    _onLoading();
    try {
      final result = await supplierRepo.createSupplier(param);
      _onCreateSupplier(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCreateSupplier(Supplier data) {
    if (!_states.isClosed) {
      _states.sink.add(CreateSupplierState(data: data));
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
