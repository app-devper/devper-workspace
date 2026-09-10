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
    if (_state.value is SupplierEditSaving) return;
    _state.value = const SupplierEditSaving();
    try {
      final updated = await updateSupplierByIdUseCase(
        SupplierUpdateParam(supplierId: supplierId, param: param),
      );
      _state.value = SupplierEditUpdated(updated);
    } on Exception catch (e) {
      _state.value = SupplierEditFailed(toFailure(e));
    }
  }

  Future<void> removeSupplierById(String supplierId) async {
    if (_state.value is SupplierEditDeleting) return;
    _state.value = const SupplierEditDeleting();
    try {
      final removed = await removeSupplierByIdUseCase(supplierId);
      _state.value = SupplierEditRemoved(removed);
    } on Exception catch (e) {
      _state.value = SupplierEditFailed(toFailure(e));
    }
  }

  void consumeError() {
    if (_state.value is SupplierEditFailed) {
      _state.value = const SupplierEditState();
    }
  }

  void consumeUpdated() {
    if (_state.value is SupplierEditUpdated) {
      _state.value = const SupplierEditState();
    }
  }

  void consumeRemoved() {
    if (_state.value is SupplierEditRemoved) {
      _state.value = const SupplierEditState();
    }
  }

  void dispose() {
    _state.dispose();
  }
}
