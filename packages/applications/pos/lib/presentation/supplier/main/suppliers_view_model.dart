// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/presentation/supplier/main/suppliers_state.dart';

import 'package:pos/domain/repositories/supplier_repository.dart';

class SuppliersViewModel {
  final SupplierRepository supplierRepo;

  SuppliersViewModel({
    required this.supplierRepo,
  });

  final _state = ValueNotifier<SuppliersState>(const SuppliersState());

  /// Shown as a snackbar and then gone. It never belonged in state: a message
  /// the view had to remember to clear is one it can forget to clear.
  final _errors = OneShot<String>();

  ValueListenable<SuppliersState> get state => _state;

  Stream<String> get errors => _errors.stream;

  Future<void> getSuppliers() async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await supplierRepo.getSuppliers();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  void dispose() {
    _state.dispose();
    _errors.dispose();
  }
}
