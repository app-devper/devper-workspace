// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/supplier/info/supplier_info_state.dart';

class SupplierInfoViewModel {
  final SupplierRepository supplierRepo;

  SupplierInfoViewModel({
    required this.supplierRepo,
  });

  final _state = ValueNotifier<SupplierInfoState>(const SupplierInfoState());

  ValueListenable<SupplierInfoState> get state => _state;

  Future<void> getSupplierInfo() async {
    try {
      final supplier = await supplierRepo.getSupplierInfo();
      _state.value = _state.value.copyWith(supplier: supplier);
    } on Exception catch (_) {}
  }

  Future<void> updateSupplierInfo(SupplierParam param) async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearUpdated: true);
    try {
      final updated = await supplierRepo.updateSupplierInfo(param);
      _state.value = _state.value.copyWith(saving: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
