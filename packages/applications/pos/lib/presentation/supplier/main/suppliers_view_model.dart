// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/main/suppliers_state.dart';

class SuppliersViewModel {
  final SupplierRepository supplierRepo;

  SuppliersViewModel({
    required this.supplierRepo,
  });

  final _state = ValueNotifier<SuppliersState>(const SuppliersState());

  ValueListenable<SuppliersState> get state => _state;

  Future<void> getSuppliers() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await supplierRepo.getSuppliers();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
