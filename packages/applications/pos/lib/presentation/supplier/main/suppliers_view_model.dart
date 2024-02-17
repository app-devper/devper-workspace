// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/main/suppliers_state.dart';

class SuppliersViewModel {
  final SupplierRepository supplierRepo;

  SuppliersViewModel({
    required this.supplierRepo,
  });

  final _states = StreamController<SuppliersState>();

  Stream<SuppliersState> get states => _states.stream;

  final _suppliers = StreamController<List<Supplier>>();

  Stream<List<Supplier>> get suppliers => _suppliers.stream;

  void getSuppliers() async {
    try {
      final result = await supplierRepo.getSuppliers();
      _onListSuppliers(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setSuppliers(List<Supplier> data) {
    _suppliers.sink.add(data);
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onListSuppliers(List<Supplier> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListSupplierState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
    _suppliers.close();
  }
}
