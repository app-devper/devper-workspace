// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
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

  /// Each outcome reaches the view once: a snackbar, or a pop with the record.
  /// Neither is drawn, so neither sits in state waiting to be cleared.
  final _updated = OneShot<Supplier>();
  final _removed = OneShot<Supplier>();
  final _errors = OneShot<String>();

  ValueListenable<SupplierEditState> get state => _state;

  Stream<Supplier> get updated => _updated.stream;

  Stream<Supplier> get removed => _removed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> updateSupplierById(String supplierId, SupplierParam param) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _updated.emit(await updateSupplierByIdUseCase(
        SupplierUpdateParam(supplierId: supplierId, param: param),
      ));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  Future<void> removeSupplierById(String supplierId) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _removed.emit(await removeSupplierByIdUseCase(supplierId));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  void dispose() {
    _state.dispose();
    _updated.dispose();
    _removed.dispose();
    _errors.dispose();
  }
}
