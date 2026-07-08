// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/usecase/supplier/remove_supplier_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_by_id_use_case.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_state.dart';

class SupplierEditViewModel {
  final UpdateSupplierByIdUseCase updateSupplierByIdUseCase;
  final RemoveSupplierByIdUseCase removeSupplierByIdUseCase;

  SupplierEditViewModel({
    required this.updateSupplierByIdUseCase,
    required this.removeSupplierByIdUseCase,
  });

  final _state = ValueNotifier<SupplierEditState>(const SupplierEditState());

  ValueListenable<SupplierEditState> get state => _state;

  Future<void> updateSupplierById(String supplierId, SupplierParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateSupplierByIdUseCase(
        SupplierUpdateParam(supplierId: supplierId, param: param),
      );
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeSupplierById(String supplierId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await removeSupplierByIdUseCase(supplierId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
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
