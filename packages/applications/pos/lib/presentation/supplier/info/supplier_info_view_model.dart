// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_info_use_case.dart';
import 'package:pos/presentation/supplier/info/supplier_info_state.dart';

class SupplierInfoViewModel {
  final GetSupplierInfoUseCase getSupplierInfoUseCase;
  final UpdateSupplierInfoUseCase updateSupplierInfoUseCase;

  SupplierInfoViewModel({
    required this.getSupplierInfoUseCase,
    required this.updateSupplierInfoUseCase,
  });

  final _state = ValueNotifier<SupplierInfoState>(const SupplierInfoState());

  /// Delivered once: the screen closes on it, nothing draws it.
  final _updated = OneShot<Supplier>();
  final _errors = OneShot<String>();

  ValueListenable<SupplierInfoState> get state => _state;

  Stream<Supplier> get updated => _updated.stream;

  Stream<String> get errors => _errors.stream;

  /// Loading the record is not a command with an outcome — the supplier lands
  /// in state, where the form renders it.
  Future<void> getSupplierInfo() async {
    try {
      final supplier = await getSupplierInfoUseCase();
      _state.value = _state.value.copyWith(supplier: supplier);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> updateSupplierInfo(SupplierParam param) async {
    _state.value = _state.value.copyWith(saving: true);
    try {
      final updated = await updateSupplierInfoUseCase(param);
      _updated.emit(updated);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }



  void dispose() {
    _state.dispose();
    _updated.dispose();
    _errors.dispose();
  }
}
